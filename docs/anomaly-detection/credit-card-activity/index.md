---
seo:
  title: Detect Unusual Credit Card Activity
  description: This recipe analyzes total credit card spend, and if it's more than the average credit card usage of a customer, the account will be flagged as a possible case of credit card theft.
---

# Detect unusual credit card activity

One way many financial institutions detect fraud is to check for unusual activity in a short period of time, raising a red flag to promptly alert their customers and confirm any recent unexpected purchases. Fraud can involve using stolen credit cards, forging checks and account numbers, multiple duplicate transactions, and more. This recipe analyzes a customer’s typical credit card spend, and flags the account when there are instances of excessive spending as a possible case of credit card theft.

![credit card being misused](../../img/credit-card-activity.jpg)

## Step by step

### Set up your environment

Set up your environment in [Confluent Cloud](https://www.confluent.io/confluent-cloud/tryfree/?utm_source=github&utm_medium=ksqldb_recipes&utm_campaign=credit-card-activity).

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

```json
--8<-- "docs/anomaly-detection/credit-card-activity/source.json"
```

--8<-- "docs/shared/manual_insert.md"

### ksqlDB code

--8<-- "docs/shared/ksqlb_processing_intro.md"

```sql
--8<-- "docs/anomaly-detection/credit-card-activity/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/anomaly-detection/credit-card-activity/manual.sql"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"
