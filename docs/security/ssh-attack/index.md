---
seo:
  title: Detecting and Analyzing SSH Attacks
  description: This recipe processes Syslog data to detect bad logins and streams out those pairs of usernames and IP addresses.
---

# Detecting and Analyzing SSH Attacks

## What is it?

There are lots of ways SSH can be abused but one of the most straightforward ways to detect a problem is to monitor for rejected logins.
This recipe processes Syslog data to detect bad logins and streams out those pairs of usernames and IP addresses.
With ksqlDB, you can filter and react to events in real time rather than performing historical analysis of Syslog data from cold storage.

![ssh-attack](../../img/ssh-attack.png)

## Get Started

--8<-- "docs/shared/ccloud_launch.md"

<a href="https://www.confluent.io/confluent-cloud/tryfree/"><img src="../../img/launch.png" /></a>

## Step-by-Step

### Setup your Environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

This recipe is a great demonstration on how to run a self-managed connector, to push syslog data into Confluent Cloud into a Kafka topic called `syslog`.

Create a file called `Dockerfile` to bundle a connect worker with `kafka-connect-syslog`:

```text
--8<-- "docs/security/ssh-attack/Dockerfile"
```

Build the custom Docker image with the command:

```
docker build \
   -t localbuild/connect_distributed_with_syslog:1.3.4 \
   -f Dockerfile .
```

Create a file called `docker-compose.yml` with the following content, substituting your Confluent Cloud connection information:

```text
--8<-- "docs/security/ssh-attack/docker-compose.yml"
```

Run the container with:

```
docker-compose up -d
```

Now you should have Syslog messages being written to the topic `syslog` in Confluent Cloud.

### Run stream processing app

Process the syslog events by flagging events with invalid users, stripping out all the other unnecessary fields, and creating just a stream of relevant information.
There are many ways to customize the resulting stream to fit the business needs: this example also demonstrates how to enrich the stream with a new field `FACILITY_DESCRIPTION` with human-readable content.

```sql
--8<-- "docs/security/ssh-attack/process.sql"
```

## Full ksqlDB Statements

--8<-- "docs/shared/code_summary.md"

Run the Syslog source connector locally, then proceed with ksqlDB to process the Syslog messages.

```sql
--8<-- "docs/security/ssh-attack/process.sql"
```
