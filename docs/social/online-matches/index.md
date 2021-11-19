---
seo:
  title: Matching Mutually Interested Online Dating Users
  description: This recipe tracks repeated interactions between users of a social network or dating site.
---

# Matching Mutually Interested Online Dating Users

_Dating sites are a very interesting use case. One of their core
features is a messaging platform, and users chatting back and forth is an
ideal fit for a real-time streaming system. But look at the site from
another angle and it's all about making connections between people,
so maybe a graph database is the right fit? Well, Kafka Connect makes
it easy to use the strengths of both in tandem, but before we go that
far, let's dig in and see how much graph-analysis we can do with some
clever ksqlDB tricks._

We'll create a messaging system, and then ask, "Which pairs of people
have made proper connections?" Defining a 'proper' connection is a
mystery for sociologists, but for our purposes we'll say two people
have connected properly if A sends a message to B, B responds, and A
follows-up. That should be enough chit-chat to get the ball rolling.

## Setup

### Set Up Your Environment

--8<-- "docs/shared/ccloud_setup.md"

### Create A Data Stream

``` sql
--8<-- "docs/social/online-matches/setup.sql"
```

### Insert Some Messages

``` sql
--8<-- "docs/social/online-matches/message_data.sql"
```

## Tracking Connections

If you look at those `message_data` events, it's clear there are a lot
of hellos bouncing around, but beyond that it's hard to see any
patterns. Let's use some queries to make sense of it. We'll build up
our answer to, "Who's connected to who?"  gradually. Before we begin,
some session settings to make sure we all get the same results:

```sql
SET 'auto.offset.reset' = 'earliest';
SET 'ksql.query.pull.table.scan.enabled' = 'true';
```

### Split By Conversation

The first step is to break the stream up into individual
conversations. If we sort the sender and receiver of each message, we
can create a unique ID for every pair that chats (or tries to start
chatting), and use that to group all the events:

```sql
CREATE TABLE conversations_v1 AS
  SELECT
    ARRAY_JOIN(ARRAY_SORT(ARRAY [send_id, recv_id]), '<>') AS conversation_id,
    COLLECT_LIST(rowtime) AS message_times
  FROM message_stream
  GROUP BY 
    ARRAY_JOIN(ARRAY_SORT(ARRAY [send_id, recv_id]), '<>');
```

Querying that:

```sql
SELECT * FROM conversations_v1;
```

```txt
+----------------+----------------------------------------------+
|CONVERSATION_ID |MESSAGE_TIMES                                 |
+----------------+----------------------------------------------+
|3<>4            |[1637318173288, 1637317383974, 1637318170245] |
|4<>5            |[1637317384066, 1637317384210, 1637317384126] |
|1<>2            |[1637317383692, 1637317383832, 1637317383887] |
|1<>3            |[1637317383778]                               |
```

(_Note that because we sorted the `[send_id, recv_id]` array, it doesn't matter if 1
was sending to 2 or 2 was sending to 1 - we get the same conversation ID for both
directions._)

### Chat By Chat

That's a big help - we can analyse conversations individually. 


Let's put each of those conversations in time order, and keep track of the sender as we go.

We do this in two steps - we'll enhance our `message_times` column to
build up a map with the `rowtime` as the key, and the `send_id` as the
value:

```sql
CREATE TABLE conversations_v2 AS
  SELECT
    ARRAY_JOIN(ARRAY_SORT(ARRAY [send_id, recv_id]), '<>') AS conversation_id,
    AS_MAP(
      COLLECT_LIST(CAST(rowtime AS STRING)),
      COLLECT_LIST(send_id)
    ) AS message_times
  FROM message_stream
  GROUP BY 
    ARRAY_JOIN(ARRAY_SORT(ARRAY [send_id, recv_id]), '<>');
```

Querying that:

```sql
SELECT * FROM conversations_v2;
```


```txt
+----------------+----------------------------------------------------+
|CONVERSATION_ID |MESSAGE_TIMES                                       |
+----------------+----------------------------------------------------+
|3<>4            |{1637317383974=3, 1637318170245=3, 1637318173288=3} |
|4<>5            |{1637317384210=5, 1637317384066=5, 1637317384126=4} |
|1<>2            |{1637317383832=2, 1637317383887=1, 1637317383692=1} |
|1<>3            |{1637317383778=1}                                   |
```

Almost right, but we want to be able to see those messages in
order. Let's turn the `message_times` map back into a sorted list with
`ENTRIES(<map>, true)`:


```sql
CREATE TABLE conversations_v3 AS
  SELECT
    ARRAY_JOIN(ARRAY_SORT(ARRAY [send_id, recv_id]), '<>') AS conversation_id,
    ENTRIES(
        AS_MAP(
          COLLECT_LIST(CAST(rowtime AS STRING)),
          COLLECT_LIST(send_id)
        ),
        true
    ) AS message_times
  FROM message_stream
  GROUP BY 
    ARRAY_JOIN(ARRAY_SORT(ARRAY [send_id, recv_id]), '<>');
```

Querying that:

```sql
SELECT * FROM conversations_v3;
```

```txt
+----------------+-------------------------------------------------------------------------+
|CONVERSATION_ID |MESSAGE_TIMES                                                            |
+----------------+-------------------------------------------------------------------------+
|3<>4            |[{K=1637317383974, V=3}, {K=1637318170245, V=3}, {K=1637318173288, V=3}] |
|4<>5            |[{K=1637317384066, V=5}, {K=1637317384126, V=4}, {K=1637317384210, V=5}] |
|1<>2            |[{K=1637317383692, V=1}, {K=1637317383832, V=2}, {K=1637317383887, V=1}] |
|1<>3            |[{K=1637317383778, V=1}]                                                 |
```

Perfect. If you pause and take a look at the `4<>5` row, you'll see we
nearly have our answer. First 5 sends a message, then 4 replies, then
5 follows-up. That's a match!  `1<>2` also matches, and it looks like
3 is getting nowhere with 4.

### Stepping Through Conversations Automatically

If our data sets were tiny, we'd be done - we can see by eye which
conversations match. To scale this up, let's teach ksqldb to step
through that sorted array of `message_times` and track the steps of the
conversation flowing back and forth. We can do with the `REDUCE`
function.

For the unfamiliar, `REDUCE` is a way of stepping through an array,
entry by entry, and boiling it down to a final result. We give it the
array (in our case, `message_times`), a starting state and a function
which can take our state and one element of the array, and give us the
next state.

Our state will track the steps in the flow, and who sent the most
recent message. We'll start with these placeholder values:

```txt
STRUCT(step := 'start', sender := CAST(-1 AS BIGINT))
```

And then build up a function, `(old_state, element) => ...`, that
considers each possible case:

* If we're at the `start` step, the next message is always an
  opener. Move to `opened`.
* If we're at `opened`, and the message has a new `send_id`, then the
  sender has changed and that's a reply. Move to `replied`.
* If we're at `replied`, and the message has changed `send_id` again,
  that's a connection! Move to `connected`.
* In any other case, there's no change.

In code that looks like this:

```sql
CREATE OR REPLACE TABLE conversation_states AS
  SELECT 
    conversation_id,
    REDUCE(
      message_times,
      STRUCT(step := 'start', last_sender := CAST(-1 AS BIGINT)),
      (old_state, element) => CASE
        WHEN old_state->step = 'start' 
          THEN struct(step := 'opened', last_sender := element->v)
        WHEN old_state->step = 'opened' AND old_state->last_sender != element->v 
          THEN struct(step := 'replied', last_sender := element->v)
        WHEN old_state->step = 'replied' AND old_state->last_sender != element->v 
          THEN struct(step := 'connected', last_sender := element->v)
        ELSE old_state
      END
    ) as state
  FROM conversations_v3;
```

Querying that:

```sql
SELECT * FROM conversation_states;
```

```txt
+----------------+--------------------------------+
|CONVERSATION_ID |STATE                           |
+----------------+--------------------------------+
|3<>4            |{STEP=opened, LAST_SENDER=3}    |
|4<>5            |{STEP=connected, LAST_SENDER=5} |
|1<>2            |{STEP=connected, LAST_SENDER=1} |
|1<>3            |{STEP=opened, LAST_SENDER=1}    |
```

### Final answer

To wrap up, let's just trim that down to the final answers:

```sql
SELECT conversation_id
FROM conversation_state
WHERE state->step = 'connected';
```

```txt
+----------------+
|CONVERSATION_ID |
+----------------+
|4<>5            |
|1<>2            |
```

## Cleanup

--8<-- "docs/shared/cleanup.md"

