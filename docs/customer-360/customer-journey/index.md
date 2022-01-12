---
seo:
  title: Track a Customer Journey
  description: This recipe demonstrates how to use ksqlDB to track a customer journey through web pages online.
---

# Track a Customer Journey

Companies with online websites, and customers that browse those websites, want to know which web pages their customers have visited.
Knowing an online customer's behavior—which pages the customer visits—can be useful for analytics, or, in case the customer calls for support, to understand exactly what the customer did beforehand.
For real-time analysis of the customer journey, you can use ksqlDB to collect the pages that a customer visited, and then send the list out for analytics in another application.

## Step by step

### Set up your environment

Provision a Kafka cluster in [Confluent Cloud](https://www.confluent.io/confluent-cloud/tryfree/?utm_source=github&utm_medium=ksqldb_recipes&utm_campaign=customer_journey).

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

For this recipe, we are interested in knowing the set of web pages visited by a given customer.

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

After processing the data, send it to Elasticsearch:

```json
--8<-- "docs/customer-360/customer-journey/sink.json"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"
