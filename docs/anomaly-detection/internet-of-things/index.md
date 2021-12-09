---
seo:
  title: Flag Unhealthy IoT Devices 
  description: This recipe demonstrates how to process and coalesce that telemetry data using ksqlDB and flag devices that warrant more investigation.
---

# Flag Unhealthy IoT Devices 

Organizations are turning towards the Internet of Things (IoT) to provide immediately actionable insights into the health and performance of various devices. However, each device can emit high volumes of telemetry data, making it difficult to accurately analyze and determine if and when something needs attention in real time. This recipe shows you how to process and coalesce that telemetry data using ksqlDB and flag devices that warrant more investigation.

![internet of things](../../img/iot.jpg)

## Step by step

### Set up your environment

Set up your environment in [Confluent Cloud](https://www.confluent.io/confluent-cloud/tryfree/?utm_source=github&utm_medium=ksqldb_recipes&utm_campaign=internet-of-things).

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

In this example, the telemetry events are stored in Postgres database tables. The connector reads from the tables and writes the data into Kafka topics in Confluent Cloud.

```json
--8<-- "docs/anomaly-detection/internet-of-things/source.json"
```

--8<-- "docs/shared/manual_insert.md"

### ksqlDB code

In this example, there is one stream of data reporting device threshold values and another reporting alarms.
The following stream processing app identifies which set of devices need to be investigated where the threshold is insufficient and alarm code is not zero.

--8<-- "docs/shared/ksqlb_processing_intro.md"

```sql
--8<-- "docs/anomaly-detection/internet-of-things/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/anomaly-detection/internet-of-things/manual.sql"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"
