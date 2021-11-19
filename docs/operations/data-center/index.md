---
seo:
  title: Monitor data center power usage 
  description: This recipe analyzes telemetry data from data center power electrical smart panels. The stream processing use cases for this data include detection of power usage levels for safety and accounting purposes.
---

# Analyze data center power usage 

Your business provides a cloud infrastructure offering. Multiple physical data center locations are partitioned into smaller tenants, occupied by your customers. These individual tenants allow customers to operate in isolation and provide you with an accounting unit to monitor and accurately invoice your customers.

The data centers consume large amounts of electricity which needs to be monitored to ensure business continuation. Additionally, the cost of the electricity needs to be accounted for and billed to the appropriate customer.

Each data center is constructed with smart electrical panels that control the power supplies to multiple customer tenants. The smart panels emit telemetry data that is captured and produced into an Apache Kafka® topic. 

![](diagram.svg)

How can we utilize [ksqlDB](https://ksqldb.io/) to process the control panel telemetry data in real time?

## Step-by-step

### Setup your Environment

--8<-- "docs/shared/ccloud_setup.md"

### Source Data

Our data center power analysis applications require data from two different sources: customer tenant information and smart control panel readings.

Typically, customer information would be sourced from an existing database. As customer occupancy changes, tables in the database would be updated and we can capture those changes and stream them into Kafka with Kafka Connect using [Change Data Capture](https://www.confluent.io/blog/cdc-and-streaming-analytics-using-debezium-kafka/).

Telemetry data may be sourced into Kafka in a variety of ways. MQTT is a popular source for Internet of Things (IoT) devices, and smart electrical panels may provide this functionality out of the box. If the panel data can be sourced from MQTT, an [MQTT Connector](https://docs.confluent.io/kafka-connect-mqtt/current/mqtt-source-connector/index.html) is available to bridge MQTT and Kafka.

Below are sample Kafka Connect configurations you could use to deploy source connectors to read data from their originating systems. 

```sql
--8<-- "docs/operations/data-center/source.json"
```

The above `MySqlCdcSource` configuration could be used to stream changes from the `customer` database's `tenant` table into the Kafka cluster. This connector is provided as [fully managed by Confluent Cloud](https://docs.confluent.io/cloud/current/connectors/cc-mysql-source-cdc-debezium.html). Fully managed connectors can be deployed using the web console or the Confluent CLI command `confluent connect create --config <file>`.

Sourcing telemtry data could be acheived using the MQTT source Connector. The above configuration is for a self-managed connector, see the documentation for details on connecting a [self-managed connector Confluent Cloud](https://docs.confluent.io/cloud/current/cp-component/connect-cloud-config.html).

If you do not have equivalent source systems to configure connectors for, you can still proceed with this recipe and utilize the sample `INSERT` statements provided below to simulate the tenant occupancy and telemetry data.

### Run stream processing app

Now you can process the data in a variety of ways.

```sql
--8<-- "docs/operations/data-center/process.sql"
```

The current state of customer tenant occupancy can be represented with a ksqlDB `TABLE`. Events streamed into the `tenant-occupancy` table represent a customer (`customer_id`) beginning an occupancy of a particular tenant (`tenant_id`). As events are observed on the `tenant-occupancy` topic, the table will model the current set of tenant occupants. You can query this table at points in time to determine which customer occupies which tenant. When customers leave a tenant, the source system will need to send a _Tombstone Record_ (an event with a valid `tenant_id` key and a `null` value). ksqlDB will process by the tombstone by removing the row with the given key from the table.

Panel sensor readings can be streamed directly into a topic or sourced from an upstream system. A `STREAM` captures the power readings when they flow from the smart panel into Kafka. Each event contains a panel identifier and the associated tenant, in addition to two power readings.

* `panel_current_utilization` represents percentage of total capacity of the panel, and is useful for business continuation monitoring.
* `tenant_kwh_usage` provides the total amount of energy consumed by the tenant in the current month. 

For the purposes of this exercise, we can simulate the tenant occupancy and panel sensor data by using ksqlDB to directly insert sample records into Kafka so we can proceed with building our stream processing applications. 

From the Confluent Cloud Console ksqlDB UI, run the following `INSERT` commands to prepare some sample data for us to work with:

```sql
--8<-- "docs/operations/data-center/manual.sql"
```

## Notes

Here, I think the gist is to have a table of what “safe” means in terms of a power range, and do a streaming join based on the actual activity. If we want to do a little billing example, too, we could join against a table for how many watts/hour costs in a particular data center.

The user who gave us this use case did a blog on almost exactly this (though with a different name and angle toward UDFs, which we can avoid). https://www.confluent.io/blog/infrastructure-monitoring-with-ksqldb-udtf/

Examples include amps each breaker is using in a panel, and how much power each tenant is consuming. You want to analyze all of this in real-time so that you can take corrective action if there’s a problem, bill customers based on their power utilization, and notify data center operators about any changes.

In this example, we can model the electrical data to ensure that power usage remains under the prescribed safe limits. As a bonus, we could compute customer bills based on usage.

Telemetry data is likely to be sourced into Kafka directly (instead of via a Kafka Connector read from a database or other source system).

```
SELECT TENANT_OCCUPANCY.CUSTOMER_ID, PANEL_POWER_READINGS.READING FROM PANEL_POWER_READINGS 
INNER JOIN TENANT_OCCUPANCY ON PANEL_POWER_READINGS.TENANT_ID = TENANT_OCCUPANCY.TENANT_ID
EMIT CHANGES LIMIT 10;
```

```
SELECT * FROM PANEL_POWER_READINGS 
WHERE READING >= 0.85
EMIT CHANGES;
```

## Full ksqlDB Statements

--8<-- "docs/shared/code_summary.md"

```sql
--8<-- "docs/operations/data-center/source.sql"

--8<-- "docs/operations/data-center/process.sql"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"
