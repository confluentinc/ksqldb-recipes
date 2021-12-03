---
seo:
  title: Optimize Omni-channel Inventory
  description: This recipe demonstrates how to use ksqlDB to ensure an up-to-date snapshot of your inventory at all times.
---

# Optimize Omni-channel Inventory

Having an up-to-date, real-time view of inventory on every item is essential in today's online marketplaces. This helps businesses maintain the optimum level of inventory—not too much and not too little—so that they can meet customer demand while minimizing inventory holding costs. This recipe demonstrates how to track and update inventory in real time, so you always have an up-to-date snapshot of your stock for both your customers and merchandising teams.

## Step by step

### Set up your environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

For this recipe, we are interested in knowing each event for an item that affects its quantity.
This creates a stream of events, where each event results in the addition or removal of inventory.

```json
--8<-- "docs/predictive-analytics/inventory/source.json"
```

--8<-- "docs/shared/manual_insert.md"

### Run the stream processing app

Create a ksqlDB `TABLE`, which is a mutable, partitioned collection that models change over time and represents what is true as of now.

--8<-- "docs/shared/ksqlb_processing_intro.md"

```sql
--8<-- "docs/predictive-analytics/inventory/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/predictive-analytics/inventory/manual.sql"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"
