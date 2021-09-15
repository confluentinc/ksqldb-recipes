---
seo:
  title: Recipe 1
  description: Recipe 1
---

# Cut to the code

```sql
--8<-- "docs/security/recipe1/connector_source.cfg"
--8<-- "docs/security/recipe1/ksqldb_statements.sql"
--8<-- "docs/security/recipe1/connector_sink.cfg"
```

# Solution

## Setup your Environment

create your CCloud cluster

--8<-- "docs/shared/ccloud_setup.md"

## Read the data in

connector_source

```json
--8<-- "docs/security/recipe1/connector_source.cfg"
```

## Run stream processing app

ksqldb_statements

```sql
--8<-- "docs/security/recipe1/ksqldb_statements.sql"
```

## Write the data out

connector_sink

```json
--8<-- "docs/security/recipe1/connector_sink.cfg"
```

