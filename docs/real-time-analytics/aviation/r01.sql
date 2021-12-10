CREATE STREAM CF_STREAM WITH (KAFKA_TOPIC='customer_flights', FORMAT='AVRO');

CREATE STREAM CF_REKEY WITH (KAFKA_TOPIC='cf_rekey') AS 
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
  FROM CF_STREAM
  PARTITION BY F_ID;

CREATE TABLE CUSTOMER_FLIGHTS_REKEYED 
  (FLIGHT_ID INT PRIMARY KEY) 
  WITH (KAFKA_TOPIC='cf_rekey', FORMAT='AVRO');