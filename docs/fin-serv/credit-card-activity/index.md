---
seo:
  title: Detecting Unusual Credit Card Activity
  description: TODO
---

# Detecting Unusual Credit Card Activity

## What is it?

In banking, fraud can involve using stolen credit cards, forging checks, misleading accounting practices, etc.
In this recipe, we show you how to analyze total credit card spend.
If it's more than the average credit card usage of a customer, the account will be flagged as a possible case of credit card theft.

![grafana](../../img/credit-card-activity.jpg)

## Run Now

Click below to launch this recipe in Confluent Cloud.

![launch](../../img/launch.png)

## Code Summary

```sql
--8<-- "docs/fin-serv/credit-card-activity/source.sql"

--8<-- "docs/fin-serv/credit-card-activity/process.sql"

--8<-- "docs/fin-serv/credit-card-activity/sink.sql"
```

## Step-by-step

### Setup your Environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

This recipe creates simulated data with the `Datagen` connector.

```sql
--8<-- "docs/fin-serv/credit-card-activity/source.sql"
```

### Run stream processing app

Now you can process the data in a variety of ways.

```sql
--8<-- "docs/fin-serv/credit-card-activity/process.sql"
```
