---
seo:
  title: Real-Time Discounting
  description: This recipe shows how to use ksqlDB to track the success of discounts for a small online business.
---

# Real-Time Discounting

Small, online retailers often run promotions in order to entice buyers and increase sales. Suppose the retailer implements a "scratch-off" promotion where customers are provided a scratch card where they will receive discount code for a random percentage (up to 50%) off of their order. How well do these promotions work? And how much does the discount percentage affect the total amount purchased in a given order? Let's find out!

## Step-by-step

### Setup your Environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

In the case of this recipe, we're interested in capturing data that reflects incoming orders as well as details on unique discount codes. Connect can easily stream in data from a database containing that information; you can use the following template as a guide to setting up a connector.

```json
--8<-- "docs/real-time-analytics/discounting/source.json"
```

--8<-- "docs/shared/manual_insert.md"

### Run stream processing app

Through a series of ksqlDB statements, we'll enrich our order data and compute some simple statistics based on that stream of enriched order data. By the end, we'll have more insights as to just how well our discount code promotion is doing. Specifically, we'll know the average order value per discount percentage as well as the average number of items purchased.

--8<-- "docs/shared/ksqlb_processing_intro.md"

```sql
--8<-- "docs/real-time-analytics/discounting/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/real-time-analytics/discounting/manual.sql"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"