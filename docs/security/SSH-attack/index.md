---
seo:
  title: Detect and Analyze SSH Attacks
  description: This ksqlDB recipe processes Syslog data to detect bad logins and streams out those pairs of usernames and IP addresses.
---

# Detect and analyze SSH attacks

There are lots of ways that SSH can be abused, but one of the most straightforward ways to detect a problem is to monitor for rejected logins.
This recipe processes Syslog data to detect bad logins and streams out those pairs of usernames and IP addresses.
With ksqlDB, you can filter and react to events in real time rather than performing historical analysis of Syslog data from cold storage.

![SSH-attack](../../img/ssh-attack.png)

## Step by Step

### Set up your environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

This recipe is a great demonstration on how to run a self-managed connector and push syslog data into Confluent Cloud into a Kafka topic called `syslog`.

Create a file called `Dockerfile` to bundle a Kafka Connect worker with `kafka-connect-syslog`:

```text
--8<-- "docs/security/SSH-attack/Dockerfile"
```

Build the custom Docker image with this command:

```
docker build \
   -t localbuild/connect_distributed_with_syslog:1.3.4 \
   -f Dockerfile .
```

Create a file called `docker-compose.yml` with the following content, substituting your Confluent Cloud connection information:

```text
--8<-- "docs/security/SSH-attack/docker-compose.yml"
```

Run the container with this:

```
docker-compose up -d
```

Now you should have Syslog messages being written to the topic `syslog` in Confluent Cloud.

### Run the stream processing app

Process the syslog events by flagging events with invalid users, stripping out all the other unnecessary fields, and creating a stream of relevant information.
There are many ways to customize the resulting stream to fit the business needs. This particular example also demonstrates how to enrich the stream with a new field `FACILITY_DESCRIPTION` and human-readable content.

--8<-- "docs/shared/ksqlb_processing_intro.md"

```sql
--8<-- "docs/security/SSH-attack/process.sql"
```

## Full ksqlDB statements

--8<-- "docs/shared/code_summary.md"

Run the Syslog source connector locally, then proceed with ksqlDB to process the Syslog messages.

```sql
--8<-- "docs/security/SSH-attack/process.sql"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"
