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

This application takes the raw network traffic packet data and creates a structured stream of events that can be processed using SQL. Using Windows and Filters the application detects a high level of connection `RESET` events from the server and isolates the potentially offending source.

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

Now that we have a useful stream of packet capture data, we're going to to about trying to detect potential DDoS attacks from the data.

Using a window and a grouping to aggregate a count of connections reset based on a filter

```sql
CREATE TABLE potential_slowloris_attacks AS 
SELECT 
  layers->ip->src, count(*) as count_connection_reset
FROM network_traffic 
WINDOW TUMBLING (SIZE 60 SECONDS)
WHERE 
  layers->tcp->flags_ack = '1' AND layers->tcp->flags_reset = '1'
GROUP BY layers->ip->src
HAVING count(*) > 10;
```

https://docs.ksqldb.io/en/latest/developer-guide/ksqldb-reference/create-table-as-select/

Final output query can be searched and monitored for connections which are 
reseting an unusual amount times within the window

```sql
select * from POTENTIAL_SLOWLORIS_ATTACKS EMIT CHANGES;
```
