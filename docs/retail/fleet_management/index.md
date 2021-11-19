---
seo:
  title: Build a Real-time Fleet Management System
  description: This recipe enriches fleet location with information about each vehicle to be able to have a real-time view with consolidation information on the entire fleet.
---

# Build a Real-time Fleet Management System

## What is it?

More and more, fleet management relies on knowing real-time information on vehicles, their locations, and vehicle telemetry.
This enables businesses to improve operational efficiency by optimizing travel routes, lowering fuel consumption, and automating service schedules.
This recipe enriches fleet location with individual vehicle information, so organizations can have a real-time consolidated view on the entire fleet.

## Step-by-step

### Setup your Environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

```json
--8<-- "docs/retail/fleet_management/source.json"
```

--8<-- "docs/shared/manual_insert.md"

### Run stream processing app

Now you can process the data in a variety of ways.
In this case, the original fleet telemetry is enriched with details about the vehicle.

--8<-- "docs/shared/ksqlb_processing_intro.md"

```sql
--8<-- "docs/retail/fleet_management/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/retail/fleet_management/manual.sql"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"
