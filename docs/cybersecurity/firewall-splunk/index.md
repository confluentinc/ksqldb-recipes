---
seo:
  title: Identify Firewall Deny Events from Splunk
  description: This recipe demonstrates how to use ksqlDB to identify and filter firewall deny events from Splunk
---

# Identify Firewall Deny Events from Splunk

In the Security Information Event Management (SIEM) world, it's important to have a scalable cyber intelligence platform so you can swiftly identify potential security threats and vulnerabilities.
However, with each source having its own set of collectors generating different dataflows, there may be too much aggregate information to analyze and take action in a timely manner.
If you first intercept those data flows from the sources, you can analyze or filter the data in any way before they are sent to an aggregator.
This recipe demonstrates how to optimize Splunk data ingestion, by using the [Splunk S2S Source connector](https://docs.confluent.io/kafka-connect-splunk-s2s/current/overview.html), which supports receiving data from a Splunk Universal Forwarder (UF) with the Splunk-2-Splunk protocol, to intercept data that would normally be sent to a Splunk HTTP Event Collector (HEC).
The stream processing application identifies and includes only `deny` events, removes unnecessary fields to reduce message size, and then sends the more targeted set of events to Splunk for indexing.
You can also extend this solution to intercept data from a variety of SIEM vendors to create a more vendor-independent solution that leverages multiple tools and analytic destinations.

## Step by step

### Set up your environment

Provision a Kafka cluster in [Confluent Cloud](https://www.confluent.io/confluent-cloud/tryfree/?utm_source=github&utm_medium=ksqldb_recipes&utm_campaign=firewall).

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/self_managed_connector.md"

This recipe shows the source as Cisco Adaptive Security Appliance (ASA) and the Splunk S2S Source connector should be run on the same host with the Splunk UF, but the same logic can be applied to any type of device.
To stream ASA data into a Kafka topic called `splunk`, create the `Dockerfile` below to bundle a connect worker with the `kafka-connect-splunk-s2s` connector:

```text
--8<-- "docs/cybersecurity/firewall-splunk/Dockerfile"
```

Build the custom Docker image with this command:

```
docker build \
   -t localbuild/connect_distributed_with_splunk-s2s:1.0.5 \
   -f Dockerfile .
```

Next, create a `docker-compose.yml` file with the following content, substituting your Confluent Cloud connection information:

```text
--8<-- "docs/cybersecurity/firewall-splunk/docker-compose.yml"
```

Run the container with the connect worker:

```
docker-compose up -d
```

Create a Splunk S2S Source connector configuration file called `connector-splunk-s2s.config`, specifying the port it should listen to:

```json
--8<-- "docs/cybersecurity/firewall-splunk/source.json"
```

Submit that connector to the connect worker:

```
curl -X POST -H "Content-Type: application/json" --data @connector-splunk-s2s.config http://localhost:8083/connectors
```

Now you should have ASA events being written to the `splunk` topic in Confluent Cloud.

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

After processing the data, send the more targeted set of events to Splunk for indexing.

```json
--8<-- "docs/cybersecurity/firewall-splunk/sink.json"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"
