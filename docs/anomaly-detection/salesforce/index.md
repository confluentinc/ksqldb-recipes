---
seo:
  title: Handle Corrupted Data From Salesforce
  description: This ksqlDB recipe streams changes of Salesforce records and identifies gap events.
---

# Handle corrupted data from Salesforce

Salesforce sends a notification when a change to a Salesforce record occurs as part of a create, update, delete, or undelete operation. However, if there is corrupt data in Salesforce, it sends a gap event instead of a change event, and these gap events should be properly handled to avoid discrepancies between Salesforce reports and internal dashboards. This recipe demonstrates how to process Salesforce data and filter corrupt events, which allows a downstream application to appropriately process and reconcile those events for accurate reporting and analytics.

![Salesforce](../../img/salesforce.jpg)

## Step by step

### Set up your environment

Set up your environment in [Confluent Cloud](https://www.confluent.io/confluent-cloud/tryfree/?utm_source=github&utm_medium=ksqldb_recipes&utm_campaign=salesforce).

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

Use Avro so ksqlDB can automatically detect the schema.

```json
--8<-- "docs/anomaly-detection/salesforce/source.json"
```

### ksqlDB code

--8<-- "docs/shared/ksqlb_processing_intro.md"

```sql
--8<-- "docs/anomaly-detection/salesforce/process.sql"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"
