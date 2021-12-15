CREATE TABLE flights (ID               INT     PRIMARY KEY
                       , ORIGIN        VARCHAR
                       , DESTINATION   VARCHAR
                       , CODE          VARCHAR
                       , SCHEDULED_DEP TIMESTAMP
                       , SCHEDULED_ARR TIMESTAMP)
              WITH (KAFKA_TOPIC='flights'
                   , FORMAT='AVRO'
                   , PARTITIONS=6);

CREATE TABLE bookings (ID            INT     PRIMARY KEY
                       , CUSTOMER_ID INT
                       , FLIGHT_ID   INT)
              WITH (KAFKA_TOPIC='bookings'
                   , FORMAT='AVRO'
                   , PARTITIONS=6);
