---
seo:
  title: Real-time geolocation based alerting
  description: This ksqlDB recipe shows real-time, personalized location based alerts. Merchant data is sourced from a database, and user location events from a mobile device. The event streams are joined to generate alerts when a user passes close to a participating merchant.
---

# Geolocation Based Alerting 

Customers are no longer satisfied with boring static websites to purchase your product or consume your service. Users demand interactive and contextualized real-time mobile applications. Providing customers with rich, real-time experiences is fundamental, and this recipe shows how ksqlDB can help build personalized location based alerts in real-time from user provided mobile geolocation data.

![alerting](../../img/loyalty.png)

## Step by step

### Set up your environment

Provision a Kafka cluster in [Confluent Cloud](https://www.confluent.io/confluent-cloud/tryfree/?utm_source=github&utm_medium=ksqldb_recipes&utm_campaign=location_based_alert).

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

This recipe assumes that you have merchant data stored in a SQL database. The merchant data includes geolocation information which will be used to match with the stream of location data from a users device. First, deploy a source connector that will read the merchant data into a Kafka topic and can be stream processed in ksqlDB.

```json
--8<-- "docs/real-time-analytics/location-based-alerting/source.json"
```

--8<-- "docs/shared/manual_insert.md"

### ksqlDB code

This application compares merchant and mobile user geolocation data to produce user proximity alerts. Initially, merchant data is sourced from a database and contains a [Geohash](https://en.wikipedia.org/wiki/Geohash) value per merchant. This data is streamed from a source database and loaded into a ksqlDB Table keyed by the Geohash to a defined precision (length of the hash). User data is streamed from mobile devices and and also includes a Geohash. As the users location changes, their Geohash is joined to the merchant table and matches result in a stream of "raw" alerts which are further refined using the ksqlDB scalar function `GEO_LOCATION` producing a final result of a `promo_alerts` containing user and merchant data with geolocation information.

--8<-- "docs/shared/ksqlb_processing_intro.md"

``` sql
--8<-- "docs/real-time-analytics/location-based-alerting/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

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

