---
seo:
  title: Check Payment Requests
  description: This ksqlDB recipe shows you how to validate payments against available funds and anti-money laundering (AML) policies.
---

# Check payment requests

With financial services, it is useful check customer payment requests in real time.
This recipe shows you how to validate payments against available funds and anti-money laundering (AML) policies.

## Step by step

### Set up your environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

```json
--8<-- "docs/fin-serv/payment-status-check/source.json"
```

--8<-- "docs/shared/manual_insert.md"

### Run the stream processing app

Now you can process the data in a variety of ways.

--8<-- "docs/shared/ksqlb_processing_intro.md"

```sql
--8<-- "docs/fin-serv/payment-status-check/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/fin-serv/payment-status-check/manual.sql"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"
