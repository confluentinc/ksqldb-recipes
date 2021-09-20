---
seo:
  title: Change Data Capture (CDC) for Orders
  description: TODO
---

# Change Data Capture (CDC) for Orders

## What is it?

TODO -- ...Transactional...Debezium to Snowflake...

Denormalising data in advance of querying is a well-established pattern for performance.
This is because most times querying a single table of data will perform better than querying across multiple at runtime.

![denormalized](../../img/denormalized-data.png)

## Get Started

Click below to launch this recipe in Confluent Cloud.

![launch](../../img/launch.png)

## Code Summary

--8<-- "docs/shared/code_summary.md"

```sql
--8<-- "docs/fin-serv/denormalization/source.sql"

--8<-- "docs/fin-serv/denormalization/process.sql"

--8<-- "docs/fin-serv/denormalization/sink.sql"
```

## Step-by-step

### Setup your Environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

Change Data Capture (CDC) for orders is being written to a SQL Server database, and there is an Oracle database with customer data.

```sql
--8<-- "docs/fin-serv/denormalization/source.sql"
```

### Run stream processing app

TODO

```sql
--8<-- "docs/fin-serv/denormalization/process.sql"
```

### Write the data out

TODO

```sql
--8<-- "docs/fin-serv/denormalization/sink.sql"
```
