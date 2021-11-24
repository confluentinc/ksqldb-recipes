SET 'auto.offset.reset' = 'earliest';

CREATE TABLE CUSTOMER_FLIGHTS 
  WITH (KAFKA_TOPIC='customer_flights') AS
  SELECT CB.*, F.*
  FROM   CUSTOMER_BOOKINGS CB
          INNER JOIN FLIGHTS F
              ON CB.FLIGHT_ID=F.ID;
