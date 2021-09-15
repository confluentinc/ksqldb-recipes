---
seo:
  title: Recipe 1
  description: Recipe 1
---

# Recipe 1

## Overview

The use case is...

## Cut to the code

```sql
--8<-- "docs/security/recipe1/source.sql"

--8<-- "docs/security/recipe1/process.sql"

--8<-- "docs/security/recipe1/sink.sql"
```

## Launch the Recipe

### Setup your Environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

This recipe uses blah blah connector.
It assumes you have setup foobar.

```sql
--8<-- "docs/security/recipe1/source.sql"
```

### Run stream processing app

Translate and filter all the things.

```sql
--8<-- "docs/security/recipe1/process.sql"
```

### Write the data out

Post-processing, send the data to this DB.

```sql
--8<-- "docs/security/recipe1/sink.sql"
```

