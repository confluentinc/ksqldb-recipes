---
seo:
  title: Handle Corrupted Data From Salesforce
  description: This recipe streams changes of Salesforce records and identifies gap events
---

# Handle Corrupted Data From Salesforce

## What is it?

Salesforce sends a notification when a change to a Salesforce record occurs as part of a create, update, delete, or undelete operation.
However, if there is corrupted data in Salesforce, it sends a gap event instead of a change event, which contains information about the change in the header, such as the change type and record ID.
These gap events need to be identified and then handled by calling a SFDC API to reconcile the events in real time.

TODO--diagram

## Get Started

--8<-- "docs/shared/ccloud_launch.md"

<a href="https://www.confluent.io/confluent-cloud/tryfree/"><img src="../../img/launch.png" /></a>

## Step-by-step

### Setup your Environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

Use Avro so ksqlDB can automatically detect the schema.

```sql
--8<-- "docs/operations/salesforce/source.sql"
```

### Run stream processing app

```sql
--8<-- "docs/operations/salesforce/process.sql"
```

## Full ksqlDB Statements

--8<-- "docs/shared/code_summary.md"

```sql
--8<-- "docs/operations/salesforce/source.sql"

--8<-- "docs/operations/salesforce/process.sql"
```
