---
seo:
  title: Modernize Mainframes for Real-Time
  description: This ksqlDB recipe demonstrates how to modernize mainframes with a real-time datastore.
---

# Modernize Mainframes for Real Time

From order processing to financial transactions, inventory control to payroll, mainframes continue to support many mission-critical applications—they still perform the majority of batch processing for many enterprises.
Data-driven enterprises need real-time access to mainframe data to feed distributed applications, microservices, and other business operations, and to enable organizations to use all their data for competitive advantage.
Confluent enables you to combine data from mainframes with real-time data across the rest of your organization, increasing the benefits of both.

- Offload with Apache Kafka to keep a more modern datastore in real-time sync with the mainframe
- Reduce overall operational expenses, including Millions of Instructions Per Second (MIPS) costs, while providing a path for architectural modernization
- Enable event-driven microservices and deliver to other systems such as data warehouses and search indexes

## Step by step

### Set up your environment

Provision a Kafka cluster in [Confluent Cloud](https://www.confluent.io/confluent-cloud/tryfree/?utm_source=github&utm_medium=ksqldb_recipes&utm_campaign=mainframe_offload).

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

```json
--8<-- "docs/real-time-analytics/mainframe-offload/source.json"
```

--8<-- "docs/shared/manual_insert.md"

### ksqlDB code

This code uses ksqlDB to create a real-time cache of mainframe account data, which can be used to offload mainframe calls to Kafka.

--8<-- "docs/shared/ksqlb_processing_intro.md"

```sql
--8<-- "docs/real-time-analytics/mainframe-offload/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/real-time-analytics/mainframe-offload/manual.sql"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"
