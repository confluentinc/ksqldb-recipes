---
seo:
  title: Recipe 1
  description: Recipe 1
---

## Solution

create your CCloud cluster

--8<-- "docs/shared/ccloud_setup.md"

connector_source

```json
--8<-- "docs/security/recipe1/connector_source.cfg"
```

ksqldb_statements

```sql
--8<-- "docs/security/recipe1/ksqldb_statements.sql"
```

connector_sink

```json
--8<-- "docs/security/recipe1/connector_sink.cfg"
```

