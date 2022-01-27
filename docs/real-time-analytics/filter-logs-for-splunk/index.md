---
seo:
  title: Filtering Confluent logs for Splunk
  description: This recipe demonstrates how to filter Confluent audit logs to Splunk for SIEM processing
---

# Filter Kafka Audit Logs for output to Splunk

In the Security Information and Event Management (SIEM) world, it's just as important to have insight into internal activities as it is to monitor for external security threats and vulnerabilities. But viewing all internal audit logs would provide too much information; you need to narrow the scope to particular events.

This recipe demonstrates how to filter audit logs in a Kafka topic and filter them for specific events and forward them to Splunk for indexing via the [Splunk Sink connector](https://docs.confluent.io/cloud/current/connectors/cc-splunk-sink.html#cc-splunk-sink).  The example data used is from [Confluent Cloud](https://www.confluent.io/confluent-cloud/tryfree/?utm_source=github&utm_medium=ksqldb_recipes&utm_campaign=filter_logs_for_splunk) audit logs.
The stream processing application filters for events involving operations on `topics`, but you can review the [structure of Confluent audit logs](https://docs.confluent.io/platform/current/security/audit-logs/audit-logs-concepts.html#audit-log-content) and extend this solution to filter for any [auditable event](https://docs.confluent.io/platform/current/security/audit-logs/audit-logs-concepts.html#auditable-events).

!!! note "Recipe Considerations" 

    This recipe assumes that the audit log records are already located in a Confluent Cloud cluster directly controlled by the end user.  If not, then the user will need to copy the audit logs from the original cluster to the one where they have their ksqlDB cluster running.  If you have a [dedicated cluster](https://docs.confluent.io/cloud/current/clusters/cluster-types.html#dedicated-clusters) one option would be to use [cluster linking](https://docs.confluent.io/cloud/current/multi-cloud/cluster-linking/index.html#cluster-linking-on-ccloud).

## Step-by-step

### Set up your environment

Provision a Kafka cluster in [Confluent Cloud](https://www.confluent.io/confluent-cloud/tryfree/?utm_source=github&utm_medium=ksqldb_recipes&utm_campaign=filter_logs_for_splunk).

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

For this recipe, you'll create a stream to read in your cluster's audit logs from a topic. Then you'll create an additional stream that filters out unwanted events and selects only the data that you need to analyze. 

--8<-- "docs/shared/manual_insert.md"

### Run the stream processing application

The first stream will set a schema for the audit log data, which will enable you to selectively pull out only the parts that you need to analyze. We'll discuss this more in the [Explanation](index.md#explanation) section.

--8<-- "docs/shared/ksqlb_processing_intro.md"

```sql
--8<-- "docs/real-time-analytics/filter-logs-for-splunk/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/real-time-analytics/filter-logs-for-splunk/manual.sql"
```

### Write the data out

--8<-- "docs/shared/connect.md"

```json
--8<-- "docs/real-time-analytics/filter-logs-for-splunk/sink.json"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"

## Explanation

The first step of this recipe was to [create a stream](https://docs.ksqldb.io/en/latest/developer-guide/ksqldb-reference/create-stream/) from the audit log topic. When creating a stream, you can assign a schema or [model the JSON](https://docs.ksqldb.io/en/latest/developer-guide/ksqldb-reference/create-stream/). After applying a model or schema, you can directly query nested sections of the data, which allows you to apply filters and only pull back the log entries that interest you. Additionally, you can cherry-pick selected fields from the nested structure, so you can limit the amount of data you retrieve with the query. The second part of the recipe leverages the applied schema to specify that you want only log entries pertaining to events on Kafka topics. 

The [JSON structure of the Confluent log entries](https://docs.confluent.io/platform/current/security/audit-logs/audit-logs-concepts.html#audit-log-content) contains several fields:

```json
{   "id": "889bdcd9-a378-4bfe-8860-180ef8efd208",
    "source": "crn:///kafka=8caBa-0_Tu-2k3rKSxY64Q",
    "specversion": "1.0",
    "type": "io.confluent.kafka.server/authorization",
    "time": "2019-10-24T16:15:48.355Z",  <---Time of the event
    "datacontenttype": "application/json",
    "subject": "crn:///kafka=8caBa-0_Tu-2k3rKSxY64Q/topic=app3-topic",
    "confluentRouting": {
        "route": "confluent-audit-log-events"
    },
    "data": {  <--- Relevant data of the event
      ...
    "authorizationInfo": {
        "granted": true,
        "operation": "Create",
        "resourceType": "Topic",  <--- You only want events involving topics
        "resourceName": "app3-topic",
        "patternType": "LITERAL",
        "superUserAuthorization": true
      }
     ... 
    }
}

```

Of these fields, you're only interested in the `time` of the event and the `data` field. The `data` field contains the specifics of the log event, which in this case is any operation where the `resourceType` is `Topic`. So the first step is to apply a schema to this JSON:

```sql
CREATE STREAM audit_log_events (
  id VARCHAR, 
  source VARCHAR, 
  specversion VARCHAR, 
  type VARCHAR, 
  time VARCHAR,  
  datacontenttype VARCHAR, 
  subject VARCHAR, 
  confluentRouting STRUCT<route VARCHAR >,  
  data STRUCT<
    serviceName VARCHAR, 
    methodName VARCHAR, 
    resourceName VARCHAR, 
    authenticationInfo STRUCT<principal VARCHAR>, 
....

) WITH (
  KAFKA_TOPIC = 'confluent-audit-log-events', 
  VALUE_FORMAT='JSON', 
  TIMESTAMP='time', 
  TIMESTAMP_FORMAT='yyyy-MM-dd''T''HH:mm:ss.SSSX',
  PARTITIONS = 6
);

```  
By supplying a schema to the ksqlDB `STREAM`, you are describing the structure of the data to ksqlDB. The top-level fields (`id` to `data`) correspond to column names. You'll notice that there are nested `STRUCT` fields representing nested JSON objects within the structure.  In the `WITH` statement you specify that ksqlDB should use the `time` field for the record timestamp and the format to parse it-`TIMESTAMP_FORMAT`.

Now that you've described the structure of the data (by applying a schema), you can create another `STREAM` that will contain only the data of interest. Let's review this query in two parts—the `CREATE` statement and the `SELECT` statement.

```sql
CREATE STREAM audit_log_topics
  WITH (
  KAFKA_TOPIC='topic-operations-audit-log', 
  PARTITIONS=6
) 
```

This `CREATE STREAM` statement specifies to use (or create, if it doesn't exist yet) a Kafka topic to store the results of the stream.

The `SELECT` part of the query is where you can drill down in the original stream and pull out only the records that interest you. Let's take a look at each line:

```sql
SELECT time, data
```

This specifies that you want only the `time` field and the nested `data` entry from the original JSON. In ksqlDB, you can access nested JSON objects using the `->` operator.

```sql
FROM  audit_log_events
```

The `FROM` clause simply tells ksqlDB to pull the records from the original stream that you created to model the Confluent log data.

```sql
WHERE data->authorizationinfo->resourcetype = 'Topic'
```

In this `WHERE` statement, you use the `->` operator to drill down through several layers of nested JSON. This statement specifies that the new stream will contain only entries involving topic operations.

