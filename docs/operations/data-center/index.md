---
seo:
  title: Monitor data center power usage 
  description: This recipe analyzes telemetry data from data center power electrical smart panels. The stream processing use cases for this data include detection of power usage levels for safety and accounting purposes.
---

# Analyze data center power usage 

Your business provides a cloud infrastructure offering. Multiple physical data center locations are partitioned into smaller tenants, assigned to your customers. These individual tenants allow customers to operate in isolation and provide you with an accounting unit to track and monitor your customers.

The data centers consume large amounts of electricity which needs to be monitored to ensure business continuation. Additionally, the cost of the electricity needs to be accounted for and billed to the appropriate customer.

Each data center is constructed with smart electrical panels that control the power supplies to multiple customer tenants. The smart panels emit telemetry data that is captured and produced into an Apache Kafka® topic. 

TODO--diagram

How can we utilize [ksqlDB](https://ksqldb.io/) to process the control panel telemetry data in real time?

## Step-by-step

### Setup your Environment

--8<-- "docs/shared/ccloud_setup.md"

### Source Data

Our streaming applications require data from two different sources: customer tenant information and smart control panel readings.

Typically, customer information may be sourced from an existing database. As customer occupancy changes, tables in the database would be updated. We can capture those changes and stream them into Kafka using Kafka Connect. 

The below examples are sample Kafka Connect configurations you could use to deploy source connectors to read data from their originating systems. For tenant occupancy data, a `MySqlCdcSource` connector could be used to stream changes from the `customer` database's `tenant` table into the Kafka cluster. 

To run this connector fully managed in Confluent Cloud, use the web console or the Confluent CLI command `confluent connect create --config <file>` to submit the connector.

```sql
--8<-- "docs/operations/data-center/source.config"
```

Telemetry data may be sourced into Kafka in a variety of ways. MQTT is a popular source for Internet of Things (IoT) devices, and smart electrical panels may provide this functionality out of the box. If the panel data can be sourced from MQTT, an [MQTT Connector](https://docs.confluent.io/kafka-connect-mqtt/current/mqtt-source-connector/index.html) is available to bridge MQTT and Kafka.

Here is an example configuration to connect a self-managed MQTT source Kafka Connector to Kafka. See the documentation for details on connecting a [self-managed connector Confluent Cloud](https://docs.confluent.io/cloud/current/cp-component/connect-cloud-config.html).

```sql
--8<-- "docs/operations/data-center/mqtt-source.config"
```

If you do not have equivalent source systems to configure connectors for, you can still proceed with this recipe and utilize the sample `INSERT` statements provided below to simulate the tenant occupancy and telemetry data.

### Run stream processing app

```sql
--8<-- "docs/operations/data-center/process.sql"
```

For the purposes of this exercise, we can simulate the tenant occupancy and telemetry data by using ksqlDB to directly insert sample records into Kafka so we can proceed with building our stream processing applications. 

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

## Full ksqlDB Statements

--8<-- "docs/shared/code_summary.md"

```sql
--8<-- "docs/operations/data-center/source.sql"

--8<-- "docs/operations/data-center/process.sql"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"
