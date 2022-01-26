---
seo:
  title: Detecting a Slowloris DDoS attack 
  description: This recipe shows you how to use ksqlDB to detect network disruption attacks by processing packet data.
---

# Detect a Slowloris DDoS network attack 

A distributed denial-of-service (DDoS) attack is a specific type of cyber attack in which a targeted system is flooded with spurious network requests using multiple hosts and IP addresses. The distributed nature of these attacks makes them more effective and difficult to mitigate. This recipe shows a strategy for ingesting and processing network packet data in an effort to detect a specific DDoS attack known as Slowloris.

![slowloris_attack](../../img/ssh-attack.jpg)

## Step by step

### Set up your environment

Provision a Kafka cluster in [Confluent Cloud](https://www.confluent.io/confluent-cloud/tryfree/?utm_source=github&utm_medium=ksqldb_recipes&utm_campaign=slowloris_ddos).

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

This recipe assumes that you have captured your network packet data and published it to a RabbitMQ queue in JSON format. An example packet may look like the following:

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

**Note**: For brevity, some fields have been removed and some names have been simplified from a typical packet capture event.

This connector will source the data into a Kafka topic for stream processing in ksqlDB.

```json
--8<-- "docs/cybersecurity/ddos/source.json"
```

--8<-- "docs/shared/manual_insert.md"

### ksqlDB code

This application takes the raw network packet data and creates a structured stream of events that can be processed using SQL. Using [windows](https://docs.ksqldb.io/en/latest/concepts/time-and-windows-in-ksqldb-queries/#windows-in-sql-queries) and filters, the application detects a high number of connection `RESET` events from the server and isolates the potentially offending source.

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

Let's break down the commands in this application and explain the individual parts.

The first step is to model the packet capture data using the ksqlDB `CREATE STREAM` command, giving our new stream the name `network_traffic`:

```sql
CREATE STREAM network_traffic
```

We then define the schema for events in the topic by declaring field names and data types using standard SQL syntax. In this snippet from the full statement:

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

We declare an event structure that contains a timestamp field, and then a child nested data structure named `layers`. Comparing the sample packet capture event with the declared structure, we see the relationships between the data and the field names and types:

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

The `CREATE STREAM ... WITH ...` [command](https://docs.ksqldb.io/en/latest/developer-guide/ksqldb-reference/create-stream/) marries the event schema with the Kafka topic. The `WITH` clause in the statement allows us to specify details about the stream. 

```sql
WITH (
  KAFKA_TOPIC='network-traffic', 
  TIMESTAMP='timestamp', 
  VALUE_FORMAT='JSON', 
  PARTITIONS=6
);
```

--8<-- "docs/shared/ksqldb_with_partitions_info.md"

We also indicate the data format of the events on the topic, using the `VALUE_FORMAT` property. Finally, we use the `TIMESTAMP` property to indicate an event field that can be used as the rowtime of the event. This would allow us to perform time-based operations based on the actual event time as provided by the captured packet data.

### Materialized view

Now that we have a useful stream of packet capture data, we're ready to try to detect potential DDoS attacks from the events.

We're going to use the ksqlDB `CREATE TABLE` command, which will create a new [materialized view](https://docs.ksqldb.io/en/latest/developer-guide/ksqldb-reference/create-table-as-select/) of the packet data.

Let's tell ksqlDB to create the table with a name of `potential_slowloris_attacks`:

```sql
CREATE TABLE potential_slowloris_attacks AS 
```

Next, we'll define the values that we want to materialize into the table. We are capturing two values:

* The source IP address, read from the `layers->ip->src` nested value in the JSON event
* The count of rows that satisfy conditions defined later in the command (obtained Using the `count` function)

```sql
SELECT 
  layers->ip->src, count(*) as count_connection_reset
```

Next, we tell ksqlDB about the event source from which to build the table: the `network_traffic` stream we defined above.

```sql
FROM network_traffic 
```

Because the stream of packet capture events is continuous, we need a way to aggregate them into a bucket that is both meaningful to our business case and useful enough that we can perform calculations with it. Here, we want to know if there are a large number of connection reset events within a given period of time. So let's tell ksqlDB that we want to create a window of events based on time:

```sql
WINDOW TUMBLING (SIZE 60 SECONDS)
```

A [tumbling window](https://docs.ksqldb.io/en/latest/concepts/time-and-windows-in-ksqldb-queries/#tumbling-window) specifies a bucket of events in a fixed time, non-overlapping, gap-less window. Here, we've specified 60-second windows.

Now that we have our events aggregated into time buckets with the fields that interest us, how do we specify that a connection has been reset? We use the ksqlDB `WHERE` clause to extract the relevant events. In this case, we define a connection as reset if the `tcp` `flags_ack` and `flag_reset` fields are set to "true".

```
WHERE 
  layers->tcp->flags_ack = '1' AND layers->tcp->flags_reset = '1'
```

We will define a potential Slowloris attack as multiple connection reset events coming from the _same_ source IP address. In order to properly aggregate (via the `count` function above), we need to group the qualifying events by the source IP:

```sql
GROUP BY layers->ip->src
```

And finally, we want to count the number of matching events within our window. In this example, we consider `10` events to signify a potential attack, but for real-world scenarios, you should adjust this variable.

```sql
HAVING count(*) > 10;
```

The end result is a `TABLE` that can be queried for information useful in alerting administrators of a potential attack. For example, you could execute a [push query](https://docs.ksqldb.io/en/latest/concepts/queries/#push) against the table as part of a monitoring and alerting pipeline.

First, for this example, we need to set the `auto.offset.reset` flag to `earliest`, which will ensure that our query runs from the beginning of the topic to produce an expected result. In a production query, you may choose to use `latest` and only capture events going forward from the time you execute the push query.

```sql
SET 'auto.offset.reset' = 'earliest';
```

This query will select all records from our materialized view, including the source IP address and count. We can use these to investigate the issue.

```
select * from POTENTIAL_SLOWLORIS_ATTACKS EMIT CHANGES;
+----------------------------+----------------------------+----------------------------+----------------------------+
|SRC                         |WINDOWSTART                 |WINDOWEND                   |COUNT_CONNECTION_RESET      |
+----------------------------+----------------------------+----------------------------+----------------------------+
|192.168.33.11               |1642017660000               |1642017720000               |14                          |
```
