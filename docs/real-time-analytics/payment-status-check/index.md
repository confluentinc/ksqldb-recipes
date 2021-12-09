---
seo:
  title: Automate Instant Payment Verifications
  description: This ksqlDB recipe shows you how to validate payments against available funds and anti-money laundering (AML) policies.
---

# Automate instant payment verifications

As digital transactions become the new norm, it’s critical to check customer payment requests in real time for suspicious activity. This means financial institutions must verify the payment by checking it against any regulatory restrictions before proceeding to process it. This recipe shows you how to validate these payments against available funds and anti-money laundering (AML) policies.

![payment verification](../../img/payment.jpg)

## Step by step

### Set up your environment

Provision a Kafka cluster in [Confluent Cloud](https://www.confluent.io/confluent-cloud/tryfree/?utm_source=github&utm_medium=ksqldb_recipes&utm_campaign=payment-status-check).

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

```json
--8<-- "docs/real-time-analytics/payment-status-check/source.json"
```

--8<-- "docs/shared/manual_insert.md"

### ksqlDB code

Now you can process the data in a variety of ways.

--8<-- "docs/shared/ksqlb_processing_intro.md"

```sql
--8<-- "docs/real-time-analytics/payment-status-check/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/real-time-analytics/payment-status-check/manual.sql"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"
