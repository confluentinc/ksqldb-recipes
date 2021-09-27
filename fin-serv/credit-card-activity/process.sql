-- Register the stream of transactions
CREATE STREAM TRANSACTIONS_RAW (ACCOUNT_ID VARCHAR, 
                                TIMESTAMP VARCHAR, 
                                CARD_TYPE VARCHAR, 
                                AMOUNT DOUBLE, 
                                IP_ADDRESS VARCHAR, 
                                TRANSACTION_ID VARCHAR) 
                           WITH (KAFKA_TOPIC='transactions',
                                 VALUE_FORMAT='JSON');

-- Repartition the stream on account_id in order to ensure that all the streams and tables are co-partitioned, which means that input records on both sides of the join have the same configuration settings for partitions.
CREATE STREAM TRANSACTIONS_SOURCE 
    WITH (VALUE_FORMAT='JSON') AS 
          SELECT * 
            FROM TRANSACTIONS_RAW 
    PARTITION BY ACCOUNT_ID;

-- Register the existing stream of customer data
CREATE STREAM CUST_RAW_STREAM (ID BIGINT, 
                               FIRST_NAME VARCHAR, 
                               LAST_NAME VARCHAR, 
                               EMAIL VARCHAR, 
                               AVG_CREDIT_SPEND DOUBLE) 
              WITH (KAFKA_TOPIC='customers', 
                    VALUE_FORMAT='JSON');

-- Repartition the customer data stream by account_id to prepare for the join
CREATE STREAM CUSTOMER_REKEYED 
    WITH (VALUE_FORMAT='JSON') AS 
            SELECT * 
              FROM CUST_RAW_STREAM 
      PARTITION BY ID;

-- Register the partitioned customer data topic as a table used for the join with the incoming stream of transactions:
CREATE TABLE customer 
WITH (KAFKA_TOPIC='CUSTOMER_REKEYED', 
      VALUE_FORMAT='JSON', 
      KEY='ID');

-- Join the transactions to customer information:
CREATE STREAM TRANSACTIONS_ENRICHED AS 
SELECT   T.ACCOUNT_ID, T.CARD_TYPE, T.AMOUNT, 
          C.FIRST_NAME + ' ' + C.LAST_NAME AS FULL_NAME, 
          C.AVG_CREDIT_SPEND 
FROM     TRANSACTIONS_SOURCE T 
          INNER JOIN CUSTOMER C 
          ON T.ACCOUNT_ID = C.ID;

-- Aggregate the stream of transactions for each account ID using a two-hour tumbling window, and filter for accounts in which the total spend in a two-hour period is greater than the customer’s average:
CREATE TABLE POSSIBLE_STOLEN_CARD AS 
SELECT   TIMESTAMPTOSTRING(WindowStart(), 'yyyy-MM-dd HH:mm:ss Z') AS WINDOW_START, 
           T.ACCOUNT_ID, T.CARD_TYPE, SUM(T.AMOUNT) AS TOTAL_CREDIT_SPEND, 
           T.FULL_NAME, MAX(T.AVG_CREDIT_SPEND) AS AVG_CREDIT_SPEND 
  FROM     TRANSACTIONS_ENRICHED T 
           WINDOW TUMBLING (SIZE 2 HOURS) 
  GROUP BY T.ACCOUNT_ID, T.CARD_TYPE, T.FULL_NAME 
  HAVING   SUM(T.AMOUNT) > MAX(T.AVG_CREDIT_SPEND) ;
