---
seo:
  title: Detect and Analyze SSH Attacks
  description: This recipe processes Syslog data and streams out pairs of usernames and IP addresses from failed login attempts.
---

# Detect and analyze SSH attacks

There are lots of ways SSH can be abused, but one of the most straightforward ways to detect a problem is to monitor for failed login attempts.
This recipe processes Syslog data and streams out pairs of usernames and IP addresses from failed login attempts.
With [ksqlDB](https://ksqldb.io/), you can filter and react to events in real time rather than performing historical analysis of Syslog data at rest.

![SSH-attack](../../img/ssh-attack.png)

## Step by step

### Set up your environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

This recipe demonstrates how to run a self-managed connector to push syslog data into a Kafka topic called `syslog` on Confluent Cloud.

Create the below `Dockerfile` to bundle a connect worker with the `kafka-connect-syslog` connector:

```text
--8<-- "docs/security/SSH-attack/Dockerfile"
```

Build the custom Docker image with this command:

```
docker build \
   -t localbuild/connect_distributed_with_syslog:1.3.4 \
   -f Dockerfile .
```

Next, create a `docker-compose.yml` file with the following content, substituting your Confluent Cloud connection information:

```text
--8<-- "docs/security/SSH-attack/docker-compose.yml"
```

Run the container with this:

```
docker-compose up -d
```

Now you should have Syslog messages being written to the `syslog` topic in Confluent Cloud.

--8<-- "docs/shared/manual_insert.md"

### Run the stream processing app

Process the syslog events by flagging events with invalid users, stripping out all the other unnecessary fields, and creating just a stream of relevant information. There are many ways to customize the resulting stream to fit the business needs: this example also demonstrates how to enrich the stream with a new field `FACILITY_DESCRIPTION` with human-readable content.

--8<-- "docs/shared/ksqlb_processing_intro.md"

```sql
--8<-- "docs/security/SSH-attack/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/operations/data-center/manual.sql"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"

## Explanation
