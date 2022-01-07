---
seo:
  title: Track Customer Journey
  description: This recipe demonstrates how to use ksqlDB to track a customer journey through webpages online.
---

# Track Customer Journey

Companies that have an online website, and customers that browse through it, want to know which webpages the customers have visited.
Knowing what the online customer behavior is—which pages does a customer visit—can be useful for analytics and to understand what exactly they did if they call in for support.
For real-time analysis of the customer journey, you can use ksqlDB to collect the pages that a customer visited, and then send the list out for analytics in another application.

## Step by step

### Set up your environment

Provision a Kafka cluster in [Confluent Cloud](https://www.confluent.io/confluent-cloud/tryfree/?utm_source=github&utm_medium=ksqldb_recipes&utm_campaign=customer_journey).

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

For this recipe, we are interested in knowing the set of webpages visited by a given customer.

```json
--8<-- "docs/customer-360/customer-journey/source.json"
```

--8<-- "docs/shared/manual_insert.md"

### ksqlDB code

--8<-- "docs/shared/ksqlb_processing_intro.md"

```sql
--8<-- "docs/customer-360/customer-journey/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/customer-360/customer-journey/manual.sql"
```

### Write the data out

After processing the data, send it to Elasticsearch.

```json
--8<-- "docs/customer-360/customer-journey/sink.json"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"
