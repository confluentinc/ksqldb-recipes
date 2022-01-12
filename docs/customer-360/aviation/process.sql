SET 'auto.offset.reset' = 'earliest';

CREATE TABLE customers (ID             INT     PRIMARY KEY
                       , NAME           VARCHAR
                       , ADDRESS        VARCHAR
                       , EMAIL          VARCHAR
                       , PHONE          VARCHAR
                       , LOYALTY_STATUS VARCHAR)
              WITH (KAFKA_TOPIC = 'customers'
                   , FORMAT = 'AVRO'
                   , PARTITIONS = 6
);

CREATE TABLE flights (ID               INT     PRIMARY KEY
                       , ORIGIN        VARCHAR
                       , DESTINATION   VARCHAR
                       , CODE          VARCHAR
                       , SCHEDULED_DEP TIMESTAMP
                       , SCHEDULED_ARR TIMESTAMP)
              WITH (KAFKA_TOPIC = 'flights'
                   , FORMAT = 'AVRO'
                   , PARTITIONS = 6
);

CREATE TABLE bookings (ID            INT     PRIMARY KEY
                       , CUSTOMER_ID INT
                       , FLIGHT_ID   INT)
              WITH (KAFKA_TOPIC = 'bookings'
                   , FORMAT = 'AVRO'
                   , PARTITIONS = 6
);

CREATE TABLE customer_bookings AS 
  SELECT C.*, B.ID, B.FLIGHT_ID
  FROM   bookings B
          INNER JOIN customers C
              ON B.CUSTOMER_ID = C.ID;

CREATE TABLE customer_flights 
  WITH (KAFKA_TOPIC = 'customer_flights') AS
  SELECT CB.*, F.*
  FROM   customer_bookings CB
          INNER JOIN flights F
              ON CB.FLIGHT_ID = F.ID;

CREATE STREAM cf_stream WITH (KAFKA_TOPIC = 'customer_flights', FORMAT = 'AVRO');

CREATE STREAM cf_rekey WITH (KAFKA_TOPIC = 'cf_rekey') AS 
  SELECT F_ID                 AS FLIGHT_ID
        , CB_C_ID             AS CUSTOMER_ID
        , CB_C_NAME           AS CUSTOMER_NAME
        , CB_C_ADDRESS        AS CUSTOMER_ADDRESS
        , CB_C_EMAIL          AS CUSTOMER_EMAIL
        , CB_C_PHONE          AS CUSTOMER_PHONE
        , CB_C_LOYALTY_STATUS AS CUSTOMER_LOYALTY_STATUS
        , F_ORIGIN            AS FLIGHT_ORIGIN
        , F_DESTINATION       AS FLIGHT_DESTINATION
        , F_CODE              AS FLIGHT_CODE
        , F_SCHEDULED_DEP     AS FLIGHT_SCHEDULED_DEP
        , F_SCHEDULED_ARR     AS FLIGHT_SCHEDULED_ARR
  FROM cf_stream
  PARTITION BY F_ID;

CREATE TABLE customer_flights_rekeyed 
  (FLIGHT_ID INT PRIMARY KEY) 
  WITH (KAFKA_TOPIC = 'cf_rekey', FORMAT = 'AVRO');

CREATE STREAM flight_updates (ID          INT KEY
                            , FLIGHT_ID   INT
                            , UPDATED_DEP TIMESTAMP
                            , REASON      VARCHAR
                             )
              WITH (KAFKA_TOPIC = 'flight_updates'
                   , FORMAT = 'AVRO'
                   , PARTITIONS = 6
);

CREATE STREAM customer_flight_updates AS
  SELECT  CUSTOMER_NAME
      , FU.REASON      AS FLIGHT_CHANGE_REASON 
      , FU.UPDATED_DEP AS FLIGHT_UPDATED_DEP
      , FLIGHT_SCHEDULED_DEP 
      , CUSTOMER_EMAIL
      , CUSTOMER_PHONE
      , FLIGHT_DESTINATION
      , FLIGHT_CODE
  FROM flight_updates FU
        INNER JOIN customer_flights_rekeyed CB
        ON FU.FLIGHT_ID = CB.FLIGHT_ID
  EMIT CHANGES;
