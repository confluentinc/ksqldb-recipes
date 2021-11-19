---
seo:
  title: Coalesce Telemetry
  description: This recipe demonstrates how to use ksqlDB to process telemetry for devices in Internet of Things (IoT) and set thresholds
---

# Coalesce Telemetry

With Internet of Things (IoT), devices can emit a lot of telemetry, and it may be difficult to analyze that information to determine if something is "wrong".
This recipe shows you how to process and coalesce that telemetry using ksqlDB and flag devices that warrant more investigation.

## Step-by-Step

### Setup your Environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

In this example, the telemetry is stored in two tables in a database and is read into 2 Kafka topics in Confluent Cloud.

```json
--8<-- "docs/internet-of-things/coalesce/source.json"
```

--8<-- "docs/shared/manual_insert.md"

### Run stream processing app

In this example, there is one stream of data reporting device threshold values and another reporting alarms.
The following stream processing app identifies which set of devices need to be investigated where threshold is insufficient and alarm code is not zero.

--8<-- "docs/shared/ksqlb_processing_intro.md"

```sql
--8<-- "docs/internet-of-things/coalesce/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/internet-of-things/coalesce/manual.sql"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"
