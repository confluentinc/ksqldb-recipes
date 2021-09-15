---
seo:
  title: Detecting and Analyzing SSH Attacks
  description: TODO
---

# Detecting and Analyzing SSH Attacks

## What is it?

There are lots of ways SSH can be abused but one of the most straightforward ways to detect a problem is to monitor for rejected logins.
This recipe tracks Syslog data and streams out pairs of usernames and IPs of bad logins.

![ssh-attack](../../img/ssh-attack.png)

## Cut to the code

![launch](../../img/launch.png)

Run the Syslog source connector to push syslog data into Confluent Cloud into a Kafka topic called `syslog`.

Then proceed with ksqlDB to process the Syslog messages.

```sql
--8<-- "docs/security/ssh-attack/process.sql"
```

## Launch Step-by-Step

### Setup your Environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

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

TODO

```sql
--8<-- "docs/security/ssh-attack/process.sql"
```
