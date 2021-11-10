---
seo:
  title: Coalesce Telemetry for Internet of Things
  description: This recipe demonstrates how to use ksqlDB to process telemetry for devices in Internet of Things and set thresholds
---

# Coalesce Telemetry for Internet of Things

## What is it?

With Internet of Things, devices can emit a lot of telemetry, and it may be difficult to analyze that information to determine if something is "wrong".
This recipe shows you how to process and coalesce that telemetry using ksqlDB and flag devices that warrant more investigation.

## Get Started

--8<-- "docs/shared/ccloud_launch.md"

<a href="https://www.confluent.io/confluent-cloud/tryfree/"><img src="../../img/launch.png" /></a>

## Step-by-Step

### Setup your Environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

TODO

```sql
--8<-- "docs/internet-of-things/coalesce/source.sql"
```

--8<-- "docs/shared/manual_insert.md"

### Run stream processing app

TODO

```sql
--8<-- "docs/internet-of-things/coalesce/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/internet-of-things/coalesce/manual.sql"
```

## Full ksqlDB Statements

--8<-- "docs/shared/code_summary.md"

```sql
--8<-- "docs/internet-of-things/coalesce/source.sql"

--8<-- "docs/internet-of-things/coalesce/process.sql"
```
