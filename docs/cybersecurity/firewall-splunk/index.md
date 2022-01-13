---
seo:
  title: Identify Firewall Deny Events from Splunk
  description: This recipe demonstrates how to use ksqlDB to identify and filter firewall deny events from Splunk.
---

# Identify Firewall Deny Events from Splunk

In the Security Information and Event Management (SIEM) world, it's important to have a scalable cyber intelligence platform so that you can swiftly identify potential security threats and vulnerabilities.
But with each source having its own set of collectors generating different data flows, there may be too much aggregate information for you to analyze it and take action in a timely manner.
If you start by intercepting those data flows as they arrive from their sources, you can analyze or filter the data in any way you wish before the data is sent to an aggregator.

This recipe demonstrates how to optimize Splunk data ingestion by using the [Splunk S2S Source connector](https://docs.confluent.io/kafka-connect-splunk-s2s/current/overview.html), which can receive data from a Splunk Universal Forwarder (UF) with the Splunk 2 Splunk protocol, to intercept data that would normally be sent to a Splunk HTTP Event Collector (HEC).
The stream processing application filters for `deny` events, removes unnecessary fields to reduce message size, and then sends the new, targeted set of events to Splunk for indexing.
You can also extend this solution to intercept data from a variety of SIEM vendors and create a vendor-independent solution that leverages multiple tools and analytic destinations.

## Step by step

### Set up your environment

Provision a Kafka cluster in [Confluent Cloud](https://www.confluent.io/confluent-cloud/tryfree/?utm_source=github&utm_medium=ksqldb_recipes&utm_campaign=firewall).

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/self_managed_connector.md"

This recipe shows the source as Cisco Adaptive Security Appliance (ASA) and the Splunk S2S Source connector should be run on the same host as the Splunk UF, but the same logic can be applied to any type of device.

To stream ASA data into a Kafka topic called `splunk`, create the `Dockerfile` below to bundle a Kafka Connect worker with the `kafka-connect-splunk-s2s` connector:

```text
--8<-- "docs/cybersecurity/firewall-splunk/Dockerfile"
```

Build the custom Docker image using the following `docker` command:

```
docker build \
   -t localbuild/connect_distributed_with_splunk-s2s:1.0.5 \
   -f Dockerfile .
```

Next, create a `docker-compose.yml` file with the following content, substituting your Confluent Cloud connection information:

```text
--8<-- "docs/cybersecurity/firewall-splunk/docker-compose.yml"
```

Run the container with the Connect worker:

```
docker-compose up -d
```

Create a configuration file, `connector-splunk-s2s.config`, for the Splunk S2S Source connector, specifying the port that the connector will use:

```json
--8<-- "docs/cybersecurity/firewall-splunk/source.json"
```

Submit that connector to the Connect worker:

```
curl -X POST -H "Content-Type: application/json" --data @connector-splunk-s2s.config http://localhost:8083/connectors
```

You now should have ASA events being written to the `splunk` topic in Confluent Cloud.

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

After processing the data, send the targeted set of events to Splunk for indexing:

```json
--8<-- "docs/cybersecurity/firewall-splunk/sink.json"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"
