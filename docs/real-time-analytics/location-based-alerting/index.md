---
seo:
  title: Real-Time Geolocation-Based Alerting
  description: This ksqlDB recipe demonstrates how to create real-time, personalized, location-based alerts. Merchant data is sourced from a database, and user location events are sourced from a mobile device. The event streams are joined to generate alerts when a user passes close to a participating merchant.
---

# Geolocation-Based Alerting 

Customers are no longer satisfied with using boring static websites to purchase your product or consume your service. Users demand interactive and contextualized real-time mobile applications. Providing customers with rich, real-time experiences is fundamental, and this recipe shows how ksqlDB can help to build personalized, location-based alerts in real time with user-provided mobile geolocation data.

## Step by step

### Set up your environment

Provision a Kafka cluster in [Confluent Cloud](https://www.confluent.io/confluent-cloud/tryfree/?utm_source=github&utm_medium=ksqldb_recipes&utm_campaign=location_based_alert).

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

This recipe assumes that you have merchant data stored in an SQL database. The merchant data includes geolocation information, which will be matched with the stream of location data from a user's device. First, deploy a source connector that will read the merchant data into a Kafka topic for stream processing in ksqlDB.

```json
--8<-- "docs/real-time-analytics/location-based-alerting/source.json"
```

--8<-- "docs/shared/manual_insert.md"

### ksqlDB code

This application compares merchant and mobile user geolocation data to produce user proximity alerts. Initially, merchant data is sourced from a database and contains a [Geohash](https://en.wikipedia.org/wiki/Geohash) value per merchant. This data is streamed from a source database and loaded into a ksqlDB table, keyed by the Geohash to a defined precision (the length of the hash). User location data is streamed from mobile devices and is joined to the merchant table by the Geohash. Location events that match are published to a "raw" alerts stream, which is further refined using the ksqlDB scalar function `GEO_LOCATION`. This produces a final result of `promo_alerts`, which contains user and merchant data with geolocation information.

--8<-- "docs/shared/ksqlb_processing_intro.md"

``` sql
--8<-- "docs/real-time-analytics/location-based-alerting/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

**Note:**
The below manual insert commands must be executed in two discrete steps, see the code comments for details.

```sql
--8<-- "docs/real-time-analytics/location-based-alerting/manual.sql"
```

## Write the data out

Sinking the promotion alerts out to Elasticsearch could facilitate further search processing:

```json
--8<-- "docs/real-time-analytics/location-based-alerting/sink.json"
```

## Cleanup

--8<-- "docs/shared/cleanup.md"

