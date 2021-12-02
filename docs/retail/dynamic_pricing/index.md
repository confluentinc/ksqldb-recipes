---
seo:
  title: Set Dynamic Pricing
  description: This recipe demonstrates how to use ksqlDB to set dynamic pricing in an online marketplace.
---

# Set dynamic pricing

An online marketplace keeps track of statistics regarding pricing: lowest, median, etc.
These statistics enable buyers and sellers to make dynamic offers based on historical sales events.

## Step by Step

### Set up your environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

For this recipe, we are interested in knowing each marketplace event for an item, specifically its pricing. 
This creates a stream of events, upon which real-time stream processing can keep state and calculate pricing statistics.

```json
--8<-- "docs/retail/dynamic_pricing/source.json"
```

--8<-- "docs/shared/manual_insert.md"

### Run the stream processing app

--8<-- "docs/shared/ksqlb_processing_intro.md"

```sql
--8<-- "docs/retail/dynamic_pricing/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/retail/dynamic_pricing/manual.sql"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"
