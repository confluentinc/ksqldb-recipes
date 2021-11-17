---
seo:
  title: Check Payment Requests
  description: This ksqlDB recipe shows you how to validate payments against available funds and anti-money-laundering (AML) policies
---

# Check Payment Requests

## What is it?

With financial services, it is useful to do real-time checking of customer payment requests.
This recipe shows you how to validate payments against available funds and anti-money-laundering (AML) policies.

## Step-by-step

### Setup your Environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

```json
--8<-- "docs/fin-serv/payment-status-check/source.json"
```

--8<-- "docs/shared/manual_insert.md"

### Run stream processing app

Now you can process the data in a variety of ways.

```sql
--8<-- "docs/fin-serv/payment-status-check/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/fin-serv/payment-status-check/manual.sql"
```
