---
seo:
  title: Build Customer Loyalty Programs
  description: This recipe tracks customers' purchasing patterns, generating tailored rewards for a loyalty scheme.
---

# Build Customer Loyalty Programs

Customer loyalty programs are everywhere in retail, even if it's as simple as "Get 10 stamps for a free coffee." However, in order to create a more sophisticated rewards program that engages customers at the right place and time, multiple data streams need to be aggregated to properly apply the right promotions. This recipe showcases how a coffee shop has implemented three separate promotions at the same time:

- A simple "the more you buy, the bigger your discount" benefit
- An online version of "Buy N, get 1 free" recurring reward 
- A customizable program that looks at individual customer behavior and offers tailored personalized rewards

![loyalty program](../../img/loyalty.png)

### Set up your environment

Provision a Kafka cluster in [Confluent Cloud](https://www.confluent.io/confluent-cloud/tryfree/?utm_source=github&utm_medium=ksqldb_recipes&utm_campaign=loyalty_rewards).

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

```json
--8<-- "docs/customer-360/loyalty-rewards/source.json"
```

--8<-- "docs/shared/manual_insert.md"

### ksqlDB code

In this solution, we'll look at different ways to analyze user behavior and determine which rewards we want to issue to our customers.

--8<-- "docs/shared/ksqlb_processing_intro.md"

``` sql
--8<-- "docs/customer-360/loyalty-rewards/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/customer-360/loyalty-rewards/manual.sql"
```

## Cleanup

--8<-- "docs/shared/cleanup.md"

## Explanation

### The more you buy, the bigger your discount

To start with the simplest reward scheme, let's group our customers by
how much they spend. We'll say anyone who spends over $400 is a Gold
customer, over $300 is Silver, and $200 is Bronze. Anyone else is
still climbing that reward ladder.

This query creates a simple "total by user" summary table, adding in a
extra column that groups the user's total into price bands:

```sql
CREATE TABLE sales_totals AS
  SELECT
    user_id,
    SUM(price) AS total,
    CASE
      WHEN SUM(price) > 400 THEN 'GOLD'
      WHEN SUM(price) > 300 THEN 'SILVER'
      WHEN SUM(price) > 200 THEN 'BRONZE'
      ELSE 'CLIMBING'
    END AS reward_level
  FROM enriched_purchases
  GROUP BY user_id;
```

Querying from that table, we get the following:

```sql
SET 'ksql.query.pull.table.scan.enabled' = 'true';
SELECT * FROM sales_totals;
```

Here is the result:

```txt
+--------+-------+-------------+
|USER_ID |TOTAL  |REWARD_LEVEL |
+--------+-------+-------------+
|dave    |252.99 |BRONZE       |
|rick    |453.64 |GOLD         |
|kris    |74.22  |CLIMBING     |
|yeva    |368.07 |SILVER       |
```

Kris will never get any rewards at that rate! Let's buy him a dog:

```sql
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'kris', 'dog' );
```

Repeating that same query, Fido has pushed Kris into the Silver rewards scheme:

```sql
SELECT * FROM sales_totals;
```

Here is the result:

```txt
+--------+-------+-------------+
|USER_ID |TOTAL  |REWARD_LEVEL |
+--------+-------+-------------+
|dave    |252.99 |BRONZE       |
|rick    |453.64 |GOLD         |
|kris    |324.21 |SILVER       |
|yeva    |368.07 |SILVER       |
```

So we have campaign one—a table of user reward levels, which updates
automatically every time a user makes a purchase. That data will
probably stream off to the user's account settings page so they can see
their reward levels in an app, and it will probably be read by the
billing system to calculate a fixed discount. We could also turn that
table back into a stream so that every time the reward level changes, the
user gets an email. But for now, let's move on to a more complex
use case.

### Buy five and the next one's on us

The chances are high that you have a coffee stamp card in your wallet (or
several dozen of them). To keep our test data small, we'll say our customers only need to buy five coffees to get a free
one. Whatever the number, the implementation of this scheme is
straightforward. We count up the number of drinks that they've
purchased. When that number gets to five, the next one is free, and as it
hits that sixth (free) one, we reset to zero.

```sql
CREATE TABLE caffeine_index AS
  SELECT
    user_id,
    count(*) as total,
    (count(*) % 6) AS sequence,
    (count(*) % 6) = 5 AS next_one_free
  FROM purchases
  WHERE product_id = 'coffee'
  GROUP BY user_id;
```

**NOTE:**
If you're a programmer, that modulo operator `%` is going to
be familiar. If not, you can read the `% 6` bit as the "remainder after
dividing by 6."

Selecting from that table:
```sql
SELECT * 
FROM caffeine_index;
```

```txt
+--------+------+---------+--------------+
|USER_ID |TOTAL |SEQUENCE |NEXT_ONE_FREE |
+--------+------+---------+--------------+
|dave    |1     |1        |false         |
|rick    |2     |2        |false         |
|kris    |13    |1        |false         |
|yeva    |5     |5        |true          |
```

**NOTE:**
The `total` and `sequence` columns aren't strictly needed, but they help to show what's going on.

Again, this updates in real time, so as customers complete a transaction to get their free
coffee, the flag will flip back to `false` automatically.

### Custom campaigns, tailored treats

To finish up, let's think about some bespoke marketing campaigns—one
to reward certain purchasing habits among our customers and another
to encourage them to try new things.

As Acting Vice President In Charge Of Marketing, I have decided that
anyone who has bought a dog and a beret is going to get a discount on Poodles. To figure out
who this applies to, let's scan through the purchases stream, narrow
it down to the products that we're interested in, and collect those
products in a set:

```sql
SELECT
    user_id,
    collect_set(product_id) AS products
FROM purchases
WHERE product_id IN ('dog', 'beret')
GROUP BY user_id
EMIT CHANGES;
```

Here is the result:

```txt
+-------------------------------------+-------------------------------------+
|USER_ID                              |PRODUCTS                             |
+-------------------------------------+-------------------------------------+
|yeva                                 |[beret]                              |
|kris                                 |[beret]                              |
|dave                                 |[dog]                                |
|rick                                 |[dog]                                |
|kris                                 |[beret, dog]                         |
```

That looks about right. Now we just turn that into a table, which only
shows rows that are `HAVING` both products in their purchase set:

```sql
CREATE TABLE promotion_french_poodle
  AS
  SELECT
      user_id,
      collect_set(product_id) AS products,
      'french_poodle' AS promotion_name
  FROM purchases
  WHERE product_id IN ('dog', 'beret')
  GROUP BY user_id
  HAVING ARRAY_CONTAINS( collect_set(product_id), 'dog' )
  AND ARRAY_CONTAINS( collect_set(product_id), 'beret' )
  EMIT changes;
```

Querying that looks like this:

```sql
SELECT * FROM promotion_french_poodle;
```

```txt
+------------------------+------------------------+------------------------+
|USER_ID                 |PRODUCTS                |PROMOTION_NAME          |
+------------------------+------------------------+------------------------+
|kris                    |[beret, dog]            |french_poodle           |
```

**NOTE:**
It doesn't matter which order they bought the items in or if
they bought more than one. We'll get the same result.

Lastly, let's try something with a similar query but a very different
business angle. We'd like to find all the customers who drink coffee but have never tried
tea. Maybe a discount voucher would encourage them to give it a taste?

Let's create a table that scans the purchase stream, picks out coffee
and tea, and finds the users `HAVING` bought coffee `AND NOT` tea.
To keep it meaningful, we'll also limit it to customers who've spent
at least $20 with us.


```sql
CREATE TABLE promotion_loose_leaf AS
  SELECT
      user_id,
      collect_set(product_id) AS products,
      'loose_leaf' AS promotion_name
  FROM enriched_purchases
  WHERE product_id IN ('coffee', 'tea')
  GROUP BY user_id
  HAVING ARRAY_CONTAINS( collect_set(product_id), 'coffee' )
  AND NOT ARRAY_CONTAINS( collect_set(product_id), 'tea' )
  AND sum(price) > 20;
```

Querying that table looks like this:

```sql
SELECT * FROM promotion_loose_leaf;
```

```txt
+------------------------+------------------------+------------------------+
|USER_ID                 |PRODUCTS                |PROMOTION_NAME          |
+------------------------+------------------------+------------------------+
|kris                    |[coffee]                |loose_leaf              |
```

That's enough campaigning for one day. I think it's time for a tea break...
