---
seo:
  title: Enrich Orders with Change Data Capture (CDC)
  description: This ksqlDB recipe demonstrates this principle by streaming from a SQL Server, denormalizing the data, and writing to Snowflake.
---

# Enrich orders with change data capture (CDC)

Change data capture (CDC) plays a vital role to ensure recently changed data is quickly ingested, transformed, and used by downstream analytics platforms and applications. If you have transactional events being written to a database, such as sales orders from a marketplace, you can use CDC to capture and denormalize these change events into a single table of enriched data to provide better query performance and consumption. This recipe demonstrates this principle by streaming data from a SQL Server, denormalizing the data, and writing it to Snowflake.

![denormalized](../../img/denormalized-data.png)

## Step by step

### Set up your environment

Set up your environment in [Confluent Cloud](https://www.confluent.io/confluent-cloud/tryfree/?utm_source=github&utm_medium=ksqldb_recipes&utm_campaign=denormalization).

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

Change data capture (CDC) for orders is being read from a SQL Server database, and the customer data is being read from Oracle.

```json
--8<-- "docs/real-time-analytics/denormalization/source.json"
```

--8<-- "docs/shared/manual_insert.md"

### ksqlDB code

This streams the user orders and denormalizes the data by joining facts (orders) with the dimension (customer).

--8<-- "docs/shared/ksqlb_processing_intro.md"

```sql
--8<-- "docs/real-time-analytics/denormalization/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/real-time-analytics/denormalization/manual.sql"
```

### Write the data out

Any downstream application or database can receive the denormalized data.

```json
--8<-- "docs/real-time-analytics/denormalization/sink.json"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"
