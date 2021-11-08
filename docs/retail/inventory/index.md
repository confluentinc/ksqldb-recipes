---
seo:
  title: View Real-time Inventory
  description: This recipe demonstrates how to use ksqlDB to always have an up-to-date snapshot of your inventory.
---

# View Real-time Inventory

## What is it?

Having an up-to-date view of inventory on every item is essential in today's online marketplaces.
This helps businesses maintain the optimum level of inventory—not too much and not too little—so that they can meet demand while minimizing costs.
This recipe demonstrates how to see your updated inventory in real-time, so you always have an up-to-date snapshot of your stock.

## Get Started

--8<-- "docs/shared/ccloud_launch.md"

<a href="https://www.confluent.io/confluent-cloud/tryfree/"><img src="../../img/launch.png" /></a>

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

### Run stream processing app

Create a ksqlDB `TABLE`, which is a mutable, partitioned collection that models change over time that represents what is true as of "now".

```sql
--8<-- "docs/retail/inventory/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/retail/inventory/manual.sql"
```

## Full ksqlDB Statements

--8<-- "docs/shared/code_summary.md"

```sql
--8<-- "docs/retail/inventory/source.sql"

--8<-- "docs/retail/inventory/process.sql"
```
