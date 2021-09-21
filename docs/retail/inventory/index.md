---
seo:
  title: Real-time Inventory
  description: This recipe demonstrates how to use ksqlDB to always have an up-to-date snapshot of your inventory.
---

# Real-time Inventory

## What is it?

Having an up to date view of inventory on every item is essential in today's online marketplaces.
This recipe demonstrates how to use ksqlDB to always have an up-to-date snapshot of your inventory.

## Get Started

Click below to launch this recipe in Confluent Cloud.

<a href="https://www.confluent.io/confluent-cloud/tryfree/"><img src="../../img/launch.png" /></a>

## Code Summary

--8<-- "docs/shared/code_summary.md"

```sql
--8<-- "docs/retail/inventory/source.sql"

--8<-- "docs/retail/inventory/process.sql"
```

## Step-by-Step

### Setup your Environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

For this recipe, we are interested in knowing each event for an item that affects its quantity.
This creates a stream of events, where each event results in the addition or removal of inventory.

```sql
--8<-- "docs/retail/inventory/source.sql"
```

--8<-- "docs/shared/manual_insert.md"

```sql
--8<-- "docs/retail/inventory/manual.sql"
```

### Run stream processing app

Create a ksqlDB `TABLE`, which is a mutable, partitioned collection that models change over time that represents what is true as of "now".

```sql
--8<-- "docs/retail/inventory/process.sql"
```
