---
seo:
  title: Notify passengers of a flight delay
  description: This recipe uses a stream of flight updates to notify passengers if their flight is delayed
---

# Notify passengers of a flight delay

## What is it?

Worse than having a flight delayed is not even knowing that it's been delayed, or having to get up to keep checking the monitors. 

This recipe shows how an airline can combine the data they have about passengers, their booked flights, and updates to flight plans in order to notify a passenger as soon as there is a delay to their flight. 

With ksqlDB, you react to events in real time to the benefit of your customers. 

![flight push notification](../../img/TODO.png)

## Get Started

--8<-- "docs/shared/ccloud_launch.md"

<a href="https://www.confluent.io/confluent-cloud/tryfree/"><img src="../../img/launch.png" /></a>

## Step-by-Step

### Setup your Environment

--8<-- "docs/shared/ccloud_setup.md"

### Create and populate the underlying tables

ksqlDB supports tables and streams as objects. Both are backed by Kafka topics. Here we're going to create three tables in a normalised data model to hold information about our customers, their bookings, and the flights. 

`TODO: Simple ERD of the three tables`

First off, let's create a table that will hold data about our customers: 

```sql
--8<-- "docs/transport/aviation/c01.sql"
```

This will store the data in a Kafka topic. In practice you would probably populate this directly from your application or a feed from your database using Kafka Connect. For simplicity, here we'll just load some data directly: 

```sql
insert into CUSTOMERS (id, name, address, email, phone, loyalty_status) values (1, 'Gleda Lealle', '93 Express Point', 'glealle0@senate.gov', '+351 831 301 6746', 'Silver');
insert into CUSTOMERS (id, name, address, email, phone, loyalty_status) values (2, 'Gilly Crocombe', '332 Blaine Avenue', 'gcrocombe1@homestead.com', '+33 203 565 3736', 'Silver');
insert into CUSTOMERS (id, name, address, email, phone, loyalty_status) values (3, 'Astrix Aspall', '56 Randy Place', 'aaspall2@ebay.co.uk', '+33 679 296 6645', 'Gold');
insert into CUSTOMERS (id, name, address, email, phone, loyalty_status) values (4, 'Ker Omond', '23255 Tennessee Court', 'komond3@usnews.com', '+33 515 323 0170', 'Silver');
insert into CUSTOMERS (id, name, address, email, phone, loyalty_status) values (5, 'Arline Synnott', '144 Ramsey Avenue', 'asynnott4@theatlantic.com', '+62 953 759 8885', 'Bronze');
```

Next we'll create a table of flights, and associated bookings for our customers. 


```sql
--8<-- "docs/transport/aviation/c02.sql"
```

For these two tables let's add some data. As before, this would usually come directly from your application or a stream of data from another system integrated through Kafka Connect. 

```sql
insert into flights (ID, ORIGIN, DESTINATION, CODE, SCHEDULED_DEP, SCHEDULED_ARR) values (1, 'LBA', 'AMS', '642',  '2021-11-18T06:04:00', '2021-11-18T06:48:00');
insert into flights (ID, ORIGIN, DESTINATION, CODE, SCHEDULED_DEP, SCHEDULED_ARR) values (2, 'LBA', 'LHR', '9607', '2021-11-18T07:36:00', '2021-11-18T08:05:00');
insert into flights (ID, ORIGIN, DESTINATION, CODE, SCHEDULED_DEP, SCHEDULED_ARR) values (3, 'AMS', 'TXL', '7968', '2021-11-18T08:11:00', '2021-11-18T10:41:00');
insert into flights (ID, ORIGIN, DESTINATION, CODE, SCHEDULED_DEP, SCHEDULED_ARR) values (4, 'AMS', 'OSL', '496',  '2021-11-18T11:20:00', '2021-11-18T13:25:00');
insert into flights (ID, ORIGIN, DESTINATION, CODE, SCHEDULED_DEP, SCHEDULED_ARR) values (5, 'LHR', 'JFK', '9230', '2021-11-18T10:36:00', '2021-11-18T19:07:00');
```

```sql
insert into bookings (ID, CUSTOMER_ID, FLIGHT_ID) VALUES (1,2,1);
insert into bookings (ID, CUSTOMER_ID, FLIGHT_ID) VALUES (2,1,1);
insert into bookings (ID, CUSTOMER_ID, FLIGHT_ID) VALUES (3,5,3);
insert into bookings (ID, CUSTOMER_ID, FLIGHT_ID) VALUES (4,4,2);
```

### Denormalise the data

To give us a single view of the passenger/flight data we'll denormalise down the three tables into one. First, we join the customers to bookings that they've made, and build a new table as a result: 

```sql
--8<-- "docs/transport/aviation/j01.sql"
```

From here we join to details of the flights themselves: 

```sql
--8<-- "docs/transport/aviation/j02.sql"

```

At this stage we can query the data held in the tables to show which customers are booked on which flights: 

```sql
SET 'auto.offset.reset' = 'earliest';

SELECT  CB_C_NAME           AS NAME
      , CB_C_EMAIL          AS EMAIL
      , CB_C_LOYALTY_STATUS AS LOYALTY_STATUS
      , F_ORIGIN            AS ORIGIN
      , F_DESTINATION       AS DESTINATION
      , F_CODE              AS CODE
      , F_SCHEDULED_DEP     AS SCHEDULED_DEP 
FROM CUSTOMER_FLIGHTS
EMIT CHANGES;      
```

```
+---------------+------------------------+---------------+-------+------------+-----+------------------------+
|NAME           |EMAIL                   |LOYALTY_STATUS |ORIGIN |DESTINATION |CODE |SCHEDULED_DEP           |
+---------------+------------------------+---------------+-------+------------+-----+------------------------+
|Gilly Crocombe |gcrocombe1@homestead.com|Silver         |LBA    |AMS         |642  |2021-11-18T06:04:00.000 |
|Ker Omond      |komond3@usnews.com      |Silver         |LBA    |LHR         |9607 |2021-11-18T07:36:00.000 |
|Gleda Lealle   |glealle0@senate.gov     |Silver         |LBA    |AMS         |642  |2021-11-18T06:04:00.000 |
|Ker Omond      |komond3@usnews.com      |Silver         |AMS    |TXL         |7968 |2021-11-18T08:11:00.000 |
```

The last step in denormalising the data is to set the key of the table to that of the Flight ID so that it can be joined to the updates (which we'll get to below). 

```sql
--8<-- "docs/transport/aviation/r01.sql"

```

We now have the `CUSTOMER_FLIGHTS` table, but keyed on `FLIGHT_ID`. 

### Add a stream of flight updates

In the `FLIGHTS` table above we have the scheduled departure time of a flight (`SCHEDULED_DEP`). Now let's introduce a stream of events that any flight changes will be written to. Again, we're populating it directly, but in the real world it'll be coming from elsewhere - perhaps Kafka Connect pulling the data from a JMS queue (or any of the other [hundreds of supported sources](https://hub.confluent.io)). 

```sql
--8<-- "docs/transport/aviation/c03.sql"
```

### Run stream processing app (notify customers when their flight is delayed)

By joining between our customer flight booking data and any flight updates we can provide a stream of notifications to passengers. Many platforms exist for providing the push notification, whether bespoke in-app or using a [third-party messaging tool](https://www.confluent.io/blog/building-a-telegram-bot-powered-by-kafka-and-ksqldb/). ksqlDB can integrate with these using its [REST interface](TODO), native [Java client](TODO), or one of the several [community-supported clients](TODO). 

In one ksqlDB window run the following ksqlDB query to return customer details with flight updates: 

```sql
--8<-- "docs/transport/aviation/p01.sql"
```

In another ksqlDB window add some data to the flight update stream: 

```
insert into FLIGHT_UPDATES (id, flight_id, updated_dep, reason) values (1, 2, '2021-11-18T09:00:00.000', 'Cabin staff unavailable');
insert into FLIGHT_UPDATES (id, flight_id, updated_dep, reason) values (2, 3, '2021-11-19T14:00:00.000', 'Mechanical checks');
insert into FLIGHT_UPDATES (id, flight_id, updated_dep, reason) values (3, 1, '2021-11-19T08:10:09.000', 'Icy conditions');
```

In the original window you will see the details of which passengers are impacted by which flight changes:

```
+---------------+---------------------+------------------+-------------------+------------+---------------------+---------------------+-----------------------+
|CUSTOMER_NAME  |CUSTOMER_EMAIL       |CUSTOMER_PHONE    |FLIGHT_DESTINATION |FLIGHT_CODE |FLIGHT_SCHEDULED_DEP |FLIGHT_UPDATED_DEP   |FLIGHT_CHANGE_REASON   |
+---------------+---------------------+------------------+-------------------+------------+---------------------+---------------------+-----------------------+
|Gleda Lealle   |glealle0@senate.gov  |+351 831 301 6746 |AMS                |642         |2021-11-18T06:04:00.0|2021-11-19T08:10:09.0|Icy conditions         |
|Ker Omond      |komond3@usnews.com   |+33 515 323 0170  |LHR                |9607        |2021-11-18T07:36:00.0|2021-11-18T09:00:00.0|Cabin staff unavailable|
|Arline Synnott |asynnott4@theatl.com |+62 953 759 8885  |TXL                |7968        |2021-11-18T08:11:00.0|2021-11-19T14:00:00.0|Mechanical checks      |
```

## Full ksqlDB Statements

--8<-- "docs/shared/code_summary.md"

```sql
--8<-- "docs/transport/aviation/c01.sql"
--8<-- "docs/transport/aviation/c02.sql"
--8<-- "docs/transport/aviation/j01.sql"
--8<-- "docs/transport/aviation/j02.sql"
--8<-- "docs/transport/aviation/r01.sql"
--8<-- "docs/transport/aviation/c03.sql"
--8<-- "docs/transport/aviation/p01.sql"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"