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
