---
seo:
  title: Identify Firewall Deny Events from Splunk and SIEM Optimization
  description: This recipe demonstrates how to use ksqlDB to identify and filter firewall deny events from Splunk and optimize SIEM
---

# Identify Firewall Deny Events from Splunk and SIEM Optimization

In the SIEM world, one of the biggest challenges is how to consolidate data from a variety of sources where each source may have its own set of collectors.
By putting Kafka in the middle of the solution, you can use connectors to intercept those data flows, and then analyze or filter the data in any way before they are sent to an aggregator.
This recipe demonstrates how to optimize your Splunk data ingestion using Splunk Universal Forwarders to pull raw firewall events, identify the deny events, remove unnecessary fields to reduce message size, and then send them to Splunk for indexing.

## Step by step

### Set up your environment

Provision a Kafka cluster in [Confluent Cloud](https://www.confluent.io/confluent-cloud/tryfree/?utm_source=github&utm_medium=ksqldb_recipes&utm_campaign=firewall).

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

```json
--8<-- "docs/cybersecurity/firewall-splunk/source.json"
```

--8<-- "docs/shared/manual_insert.md"

### ksqlDB code

--8<-- "docs/shared/ksqlb_processing_intro.md"

```sql
--8<-- "docs/cybersecurity/firewall-splunk/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/cybersecurity/firewall-splunk/manual.sql"
```

### Write the data out

After processing the data, send it to Splunk.

```json
--8<-- "docs/cybersecurity/firewall-splunk/sink.json"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"
