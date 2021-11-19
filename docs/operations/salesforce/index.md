---
seo:
  title: Handle Corrupted Data From Salesforce
  description: This recipe streams changes of Salesforce records and identifies gap events
---

# Handle Corrupted Data From Salesforce

Salesforce sends a notification when a change to a Salesforce record occurs as part of a create, update, delete, or undelete operation.
However, if there is corrupted data in Salesforce, it sends a gap event instead of a change event, which contains information about the change in the header, such as the change type and record ID.
These gap events need to be identified and then handled by calling a SFDC API to reconcile the events in real time.

## Step-by-step

### Setup your Environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

Use Avro so ksqlDB can automatically detect the schema.

```json
--8<-- "docs/operations/salesforce/source.json"
```

### Run stream processing app

--8<-- "docs/shared/ksqlb_processing_intro.md"

```sql
--8<-- "docs/operations/salesforce/process.sql"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"
