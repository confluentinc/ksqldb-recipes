---
seo:
  title: Denormalize Change Data Capture (CDC) for Orders
  description: This recipe demonstrates this principle by streaming from a SQL Server, denormalizing the data, and writing to Snowflake.
---

# Denormalize Change Data Capture (CDC) for Orders

## What is it?

If you have transactional events for orders in a marketplace, you can stream the Change Data Capture (CDC) and denormalize the events.
Denormalization is a well-established pattern for performance because querying a single table of enriched data will often perform better than querying across multiple at runtime.
You can consume the denormalized events from  downstream applications in your business, or stream them to another destination.
This recipe demonstrates this principle by streaming from a SQL Server, denormalizing the data, and writing to Snowflake.

![denormalized](../../img/denormalized-data.png)

## Step-by-step

### Setup your Environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

Change Data Capture (CDC) for orders is being written to a SQL Server database, and there is an Oracle database with customer data.

```json
--8<-- "docs/fin-serv/denormalization/source.json"
```

--8<-- "docs/shared/manual_insert.md"

### Run stream processing app

This streams the user orders and denormalizes the data by joining facts (orders) with the dimension (customer).

```sql
--8<-- "docs/fin-serv/denormalization/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/fin-serv/denormalization/manual.sql"
```

### Write the data out

Any downstream application or database can receive the denormalized data.

```json
--8<-- "docs/fin-serv/denormalization/sink.json"
```
