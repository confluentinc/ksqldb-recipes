---
seo:
  title: TODO: Insert title
  description: TODO: Insert description
---

# Title

TODO: Description and graphic if available

## Step-by-step

### Setup your Environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

```json
--8<-- "docs/<industry>/<new-recipe-name>/source.json"
```

--8<-- "docs/shared/manual_insert.md"

### Run stream processing app

TODO: high-level description

--8<-- "docs/shared/ksqlb_processing_intro.md"

```sql
--8<-- "docs/<industry>/<new-recipe-name>/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/<industry>/<new-recipe-name>/manual.sql"
```

### Write the data out

This part is optional

```json
--8<-- "docs/<industry>/<new-recipe-name>/sink.json"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"
