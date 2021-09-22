---
seo:
  title: Fleet Management
  description:  TODO
---

# Fleet Management

## What is it?

More and more fleet management relies on knowing real-time information on vehicles, their locations, and vehicle telemetry.
This enables businesses to improve route efficiency, fuel efficiency, automate service schedules, etc.

## Get Started

--8<-- "docs/shared/ccloud_launch.md"

<a href="https://www.confluent.io/confluent-cloud/tryfree/"><img src="../../img/launch.png" /></a>

## Step-by-step

### Setup your Environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

TODO

```sql
--8<-- "docs/retail/fleet_management/source.sql"
```

--8<-- "docs/shared/manual_insert.md"

### Run stream processing app

TODO

```sql
--8<-- "docs/retail/fleet_management/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/retail/fleet_management/manual.sql"
```

## Full ksqlDB Statements

--8<-- "docs/shared/code_summary.md"

```sql
--8<-- "docs/retail/fleet_management/source.sql"

--8<-- "docs/retail/fleet_management/process.sql"
```
