---
seo:
  title: View Real-Time Inventory
  description: This recipe demonstrates how to use ksqlDB to ensure an up-to-date snapshot of your inventory at all times.
---

# View real-time inventory

Having an up-to-date view of inventory on every item is essential in today's online marketplaces.
This helps businesses maintain the optimal level of inventory—not too much and not too little—so that they can meet demand while minimizing costs.
This recipe demonstrates how to see your updated inventory in real time so you always have a live snapshot of your stock levels.

## Step by step

### Set up your environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

For this recipe, we are interested in knowing each event for an item that affects its quantity.
This creates a stream of events, where each event results in the addition or removal of inventory.

```json
--8<-- "docs/retail/inventory/source.json"
```

--8<-- "docs/shared/manual_insert.md"

### Run the stream processing app

Create a ksqlDB `TABLE`, which is a mutable, partitioned collection that models change over time and represents what is true as of now.

--8<-- "docs/shared/ksqlb_processing_intro.md"

```sql
--8<-- "docs/retail/inventory/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/retail/inventory/manual.sql"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"
