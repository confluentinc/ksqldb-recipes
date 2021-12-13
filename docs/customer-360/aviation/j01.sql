CREATE TABLE customer_bookings AS 
  SELECT C.*, B.ID, B.FLIGHT_ID
  FROM   bookings B
          INNER JOIN CUSTOMERS C
              ON B.CUSTOMER_ID = C.ID;
