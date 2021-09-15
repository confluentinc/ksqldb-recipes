---
seo:
  title: Clickstream Data Analysis
  description: TODO
---

# Clickstream Data Analysis

## What is it?

It's like this and like that and like this and uh.

![foobar](../../img/foobar.svg)

## Cut to the code

![launch](../../img/launch.png)

```sql
--8<-- "docs/customer-360/clickstream/source.sql"

--8<-- "docs/customer-360/clickstream/process.sql"

--8<-- "docs/customer-360/clickstream/sink.sql"
```

## Launch Step-by-Step

### Setup your Environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

This recipe uses blah blah connector.
It assumes you have setup foobar.

```sql
--8<-- "docs/customer-360/clickstream/source.sql"
```

### Run stream processing app

Translate and filter all the things.

```sql
--8<-- "docs/customer-360/clickstream/process.sql"
```

### Write the data out

Post-processing, send the data to this DB.

```sql
--8<-- "docs/customer-360/clickstream/sink.sql"
```
