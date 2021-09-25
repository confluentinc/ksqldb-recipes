---
seo:
  title: Detecting Unusual Credit Card Activity
  description: This recipe analyzes total credit card spend, and if it's more than the average credit card usage of a customer, the account will be flagged as a possible case of credit card theft.
---

# Detecting Unusual Credit Card Activity

## What is it?

In banking, fraud can involve using stolen credit cards, forging checks, misleading accounting practices, etc.
This recipe analyzes total credit card spend, and if it's more than the average credit card usage of a customer, the account will be flagged as a possible case of credit card theft.

![grafana](../../img/credit-card-activity.jpg)

## Get Started

--8<-- "docs/shared/ccloud_launch.md"

<a href="https://www.confluent.io/confluent-cloud/tryfree/"><img src="../../img/launch.png" /></a>

## Step-by-step

### Setup your Environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

```sql
--8<-- "docs/fin-serv/credit-card-activity/source.sql"
```

--8<-- "docs/shared/manual_insert.md"

### Run stream processing app

Now you can process the data in a variety of ways.

```sql
--8<-- "docs/fin-serv/credit-card-activity/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/fin-serv/credit-card-activity/manual.sql"
```

## Full ksqlDB Statements

--8<-- "docs/shared/code_summary.md"

```sql
--8<-- "docs/fin-serv/credit-card-activity/source.sql"

--8<-- "docs/fin-serv/credit-card-activity/process.sql"

--8<-- "docs/fin-serv/credit-card-activity/sink.sql"
```
