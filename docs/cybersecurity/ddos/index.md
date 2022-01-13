---
seo:
  title: Detecking a Slowloris DDoS attack 
  description: A ksqlDB recipe that detects network disruption attacks by processing packet data
---

# Detect a Slowloris DDoS network attack 

Distributed denial-of-service (DDoS) attacks are specific type of cyber-attack in which a targeted system is flooded with spurious network requests using multiple hosts and IP addresses. The distributed nature of these attacks make them more effective and difficult to mitigate. This recipe shows a strategy for ingesting and processing network packet data in an effort to detect a specific DDoS attack known as Slowloris.

![slowloris_attack](../../img/ssh-attack.jpg)

## Step by step

### Set up your environment

Provision a Kafka cluster in [Confluent Cloud](https://www.confluent.io/confluent-cloud/tryfree/?utm_source=github&utm_medium=ksqldb_recipes&utm_campaign=online_dating).

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

This recipe assumes you have captured your network packet data and published it to a RabbitMQ queue in JSON format. An example packet may look like the following example. 

**Note**: To keep this recipe brief, some fields have been removed and names simplified from a typical packet capture event.

```json
{
  "timestamp": "1590682723239",
  "layers": {
    "frame": { 
      "time": "May 28, 2020 11:48:43.239564000 CST",
      "protocols": "eth:ethertype:ip:tcp"
    },
    "eth": { 
      "src": "FF:AA:C9:83:C0:21",
      "dst": "DF:ED:E3:91:D4:13"
    },
    "ip": {
      "src": "192.168.33.11",
      "src_host": "192.168.33.11",
      "dst": "192.168.33.77",
      "dst_host": "192.168.33.77"
    },
    "tcp": { 
      "srcport": "59202",
      "dstport": "443",
      "flags_ack": "1",
      "flags_reset": "0"
    }
  }
}
```

This connector will source that data into a Kafka topic and can be stream processed in ksqlDB.

```json
--8<-- "docs/cybersecurity/ddos/source.json"
```

--8<-- "docs/shared/manual_insert.md"

### ksqlDB code

This application takes the raw network packet data and creates a structured stream of events that can be processed using SQL. Using [Windows](https://docs.ksqldb.io/en/latest/concepts/time-and-windows-in-ksqldb-queries/#windows-in-sql-queries) and filters, the application detects a high number of connection `RESET` events from the server and isolates the potentially offending source.

--8<-- "docs/shared/ksqlb_processing_intro.md"

``` sql
--8<-- "docs/cybersecurity/ddos/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/cybersecurity/ddos/manual.sql"
```
## Cleanup

--8<-- "docs/shared/cleanup.md"

## Explanation

This solution uses ksqlDB's ability to [model](https://www.confluent.io/blog/ksqldb-techniques-that-make-stream-processing-easier-than-ever/) and [query](https://docs.ksqldb.io/en/latest/how-to-guides/query-structured-data/) structured data. 

### Streaming JSON

Let's break down commands in this application and explain the individual parts.

The first step is to model the packet capture data using ksqlDB's `CREATE STREAM` statement, giving our new stream the name `network_traffic`:

```sql
CREATE STREAM network_traffic
```

We then define the schema for events in the topic by declaring field names and data types using standard SQL syntax. Looking at this snippet from the full statement:

```sql
  timestamp BIGINT,
  layers STRUCT<
   ...
   ip STRUCT< 
      src VARCHAR, 
      src_host VARCHAR, 
      dst VARCHAR, 
      dst_host VARCHAR, 
      proto VARCHAR >,
   ...
```

We are declaring an event structure that contains a timestamp field and then a child nested data structure named `layers`. Comparing the sample packet capture event with the declared structure, we see the relationships between the data and the field names and types:

```json
{
  "timestamp": "1590682723239",
  "layers": {
    ...
    "ip": {
      "src": "192.168.33.11",
      "src_host": "192.168.33.11",
      "dst": "192.168.33.77",
      "dst_host": "192.168.33.77"
    },
    ...
  }
}

```

The `CREATE STREAM ... WITH ...` [statement](https://docs.ksqldb.io/en/latest/developer-guide/ksqldb-reference/create-stream/) marries together the schema for the events with the Kafka topic. The `WITH` clause in the statement allows you to specify details about the stream. 

```sql
WITH (
  KAFKA_TOPIC='network-traffic', 
  TIMESTAMP='timestamp', 
  VALUE_FORMAT='JSON', 
  PARTITIONS=6
);
```

The `KAFKA_TOPIC` property is required, and indicates the topic that will back the stream. The topic must either exist in Kafka, or the `PARTITIONS` property must be provided as well. If you're creating a stream for a topic that already exists, like would be the case when using a connector to source event data, you should remove the `PARTITIONS` property from this command.

We are also indicating the data format of the events on the topic with the `VALUE_FORMAT` property. Finally, the `TIMESTAMP` property allows us to indicate a field in the event that can be used as the rowtime of the event. This would allow us to perform time-based operations based on the actual event time as provided by the captured packet data.

### Materialized view

Now that we have a useful stream of packet capture data, we're going to go about trying to detect potential DDoS attacks from the events.

We're going to use the ksqlDB `CREATE TABLE` statement which will create a new [materialized view](https://docs.ksqldb.io/en/latest/developer-guide/ksqldb-reference/create-table-as-select/) of the packet data.

Let's tell ksqlDB to create the TABLE with a name of `potential_slowloris_attacks`:

```sql
CREATE TABLE potential_slowloris_attacks AS 
```

Next, we are going to define the values we want to materialize into the table. We are capturing two values:

* The source IP address read from the `layers->ip->src` netsted value in the JSON event
* Using the `count` function, a value that contains a count of rows that satisfy conditions defined later in the command. 

```sql
SELECT 
  layers->ip->src, count(*) as count_connection_reset
```

Next we tell ksqlDB where to source the events from to build the table, in this case, the `network_traffic` stream we defiend above.

```sql
FROM network_traffic 
```

Because the stream of packet capture events is continunous, we need a way to aggregate them into a bucket that is both meaningful to our business case and useful enough to perform calculations on. Here, we want to know if within a given period of time, there are a large number of connection reset events, so let's tell ksqlDB we want to create a window of events based on time.

```sql
WINDOW TUMBLING (SIZE 60 SECONDS)
```

A [tumbling window](https://docs.ksqldb.io/en/latest/concepts/time-and-windows-in-ksqldb-queries/#tumbling-window) specifies a bucket of events in a fixed time, non-overlapping, gap-less window. Here we've specified 60 second windows.

Now we have our events aggregated into time buckets with the fields we are interested in, how do we specifiy that a connection has been reset? We use the ksqlDB `WHERE` clause to extract the events we are interested in. Here, we define a connection as reset if the tcp `flags_ack` and `flag_reset` fields are set to "true".

```
WHERE 
  layers->tcp->flags_ack = '1' AND layers->tcp->flags_reset = '1'
```

We are going to define a potential Slowloris attack as connection reset events coming from the _same_ source IP address. In order to properly aggregate (via the `count` function above), we need to group the qualifying events by the source IP.

```sql
GROUP BY layers->ip->src
```

And finally we want to count the number of matching events within our window. In this example we are using `10` events to signify a potential attack, but this variable should be adjusted for more real world scenarios.
```sql
HAVING count(*) > 10;
```

The end result is a `TABLE` that can be queried for information useful in alerting administrators of a potential attack. Executing a [push query](https://docs.ksqldb.io/en/latest/concepts/queries/#push) against the table could be used as part of a monitoring and alerting pipleine. For example:

First, for this example, we need to set the `auto.offset.reset` flag to `earliest`, which will ensure that our query runs from the beginning of the topic to produce an expected result. In a production query, you may choose to use `latest` and only capture events going forward from the time you execute the push query.

```sql
SET 'auto.offset.reset' = 'earliest';
```

This query will select all the records from our materialized view including the source IP address and count which we can use to investigate the issue.

```
select * from POTENTIAL_SLOWLORIS_ATTACKS EMIT CHANGES;
+----------------------------+----------------------------+----------------------------+----------------------------+
|SRC                         |WINDOWSTART                 |WINDOWEND                   |COUNT_CONNECTION_RESET      |
+----------------------------+----------------------------+----------------------------+----------------------------+
|192.168.33.11               |1642017660000               |1642017720000               |14                          |
```
