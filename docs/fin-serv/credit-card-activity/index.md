---
seo:
  title: Detect Unusual Credit Card Activity
  description: This recipe analyzes total credit card spend, and if it's more than the average credit card usage of a customer, the account will be flagged as a possible case of credit card theft.
---

# Detect Unusual Credit Card Activity

In banking, fraud can involve using stolen credit cards, forging checks, misleading accounting practices, etc.
This recipe analyzes total credit card spend.
If a customer exceeds their average spend, the account will be flagged as a possible case of credit card theft.

![credit card being misused](../../img/credit-card-activity.jpg)

## Step-by-step

### Setup your Environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

```json
--8<-- "docs/fin-serv/credit-card-activity/source.json"
```

--8<-- "docs/shared/manual_insert.md"

### Run stream processing app

Now you can process the data in a variety of ways.

--8<-- "docs/shared/ksqlb_processing_intro.md"

```sql
--8<-- "docs/fin-serv/credit-card-activity/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/fin-serv/credit-card-activity/manual.sql"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"
