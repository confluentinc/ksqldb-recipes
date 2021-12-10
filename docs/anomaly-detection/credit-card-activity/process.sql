-- Register the stream of transactions
CREATE STREAM FD_TRANSACTIONS (
  ACCOUNT_ID BIGINT, 
  TIMESTAMP VARCHAR, 
  CARD_TYPE VARCHAR, 
  AMOUNT DOUBLE, 
  IP_ADDRESS VARCHAR, 
  TRANSACTION_ID VARCHAR
) WITH (
  KAFKA_TOPIC='FD_transactions',
  VALUE_FORMAT='JSON', 
  PARTITIONS=6
);

-- Register the stream of customer data
CREATE STREAM FD_CUST_RAW_STREAM (
  ID BIGINT, 
  FIRST_NAME VARCHAR, 
  LAST_NAME VARCHAR, 
  EMAIL VARCHAR, 
  AVG_CREDIT_SPEND DOUBLE
) WITH (
  KAFKA_TOPIC='FD_customers', 
  VALUE_FORMAT='JSON', 
  PARTITIONS=6
);

-- Repartition the customer data stream by account_id to prepare for the join
CREATE STREAM FD_CUSTOMER_REKEYED WITH (KAFKA_TOPIC='FD_CUSTOMER_REKEYED') AS
  SELECT * 
  FROM FD_CUST_RAW_STREAM 
  PARTITION BY ID;

-- Register the partitioned customer data topic as a table
-- used for the join with the stream of transactions:
CREATE TABLE FD_CUSTOMERS (
  ID BIGINT PRIMARY KEY,
  FIRST_NAME VARCHAR, 
  LAST_NAME VARCHAR, 
  EMAIL VARCHAR, 
  AVG_CREDIT_SPEND DOUBLE
) WITH (
  KAFKA_TOPIC='FD_CUSTOMER_REKEYED',
  VALUE_FORMAT='JSON',
  PARTITIONS=6
);

-- Join the transactions to customer information
CREATE STREAM FD_TRANSACTIONS_ENRICHED WITH (KAFKA_TOPIC='transactions_enriched') AS
  SELECT
    T.ACCOUNT_ID,
    T.CARD_TYPE,
    T.AMOUNT, 
    C.FIRST_NAME + ' ' + C.LAST_NAME AS FULL_NAME, 
    C.AVG_CREDIT_SPEND 
  FROM FD_TRANSACTIONS T
  INNER JOIN FD_CUSTOMERS C
  ON T.ACCOUNT_ID = C.ID;

-- Aggregate the stream of transactions for each account ID using a two-hour
-- tumbling window, and filter for accounts in which the total spend in a
-- two-hour period is greater than the customer’s average:
CREATE TABLE FD_POSSIBLE_STOLEN_CARD WITH (KAFKA_TOPIC='possible_stolen_card',KEY_FORMAT='json') AS
  SELECT
    TIMESTAMPTOSTRING(WINDOWSTART, 'yyyy-MM-dd HH:mm:ss Z') AS WINDOW_START, 
    T.ACCOUNT_ID,
    T.CARD_TYPE,
    SUM(T.AMOUNT) AS TOTAL_CREDIT_SPEND, 
    T.FULL_NAME,
    MAX(T.AVG_CREDIT_SPEND) AS AVG_CREDIT_SPEND 
  FROM FD_TRANSACTIONS_ENRICHED T
  WINDOW TUMBLING (SIZE 2 HOURS) 
  GROUP BY T.ACCOUNT_ID, T.CARD_TYPE, T.FULL_NAME 
  HAVING SUM(T.AMOUNT) > MAX(T.AVG_CREDIT_SPEND);
