---
seo:
  title: Optimize your SIEM Platform 
  description: This recipe demonstrates how to use ksqlDB to enrich and process security event data from SIEM platforms 
---

# Optimize your SIEM Platform

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

<!-- TODO different image -->
![SSH-attack](../../img/ssh-attack.jpg)

## Step by step

### Set up your environment

Provision a Kafka cluster in [Confluent Cloud](https://www.confluent.io/confluent-cloud/tryfree/?utm_source=github&utm_medium=ksqldb_recipes&utm_campaign=firewall).

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/self_managed_connector.md"

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

```text
--8<-- "docs/cybersecurity/firewall-splunk/Dockerfile"
```

Build the custom Docker image with this command:

```
docker build \
   -t localbuild/<TODO>:1.0.5 \
   -f Dockerfile .
```

Next, create a `docker-compose.yml` file with the following content, substituting your Confluent Cloud connection information:

```text
--8<-- "docs/cybersecurity/siem/docker-compose.yml"
```

Run the container with the connect worker:

```
docker-compose up -d
```

Create a Zeek Source connector configuration file called `connector-zeek.config`, specifying the port it should listen to:

```json
--8<-- "docs/cybersecurity/siem/source.json"
```

Submit that connector to the connect worker:

```
curl -X POST -H "Content-Type: application/json" --data @connector-zeek.config http://localhost:8083/connectors
```
<TODO> Now you should have network being written to the `splunk` topic in Confluent Cloud.

--8<-- "docs/shared/manual_insert.md"

### ksqlDB code

--8<-- "docs/shared/ksqlb_processing_intro.md"

```sql
--8<-- "docs/cybersecurity/siem/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/cybersecurity/siem/manual.sql"
```

### Write the data out

After processing the data, send the more targeted set of events to Splunk for indexing.

```json
--8<-- "docs/cybersecurity/siem/sink.json"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"

