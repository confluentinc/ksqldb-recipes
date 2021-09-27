-- Stream of user orders:
CREATE STREAM orders (ORDER_ID BIGINT,
                      CUSTOMER_ID BIGINT,
                      ITEM VARCHAR,
                      ORDER_TOTAL_USD DOUBLE)
    ) with (kafka_topic = 'orders',
            value_format = 'json');

-- Register the existing stream of customer data
CREATE STREAM CUST_RAW_STREAM (ID BIGINT,
                               FIRST_NAME VARCHAR,
                               LAST_NAME VARCHAR,
                               EMAIL VARCHAR)
              WITH (KAFKA_TOPIC='customers',
                    VALUE_FORMAT='JSON');

-- Register the customer data topic as a table
CREATE TABLE customer
WITH (KAFKA_TOPIC='CUST_RAW_STREAM',
      VALUE_FORMAT='JSON',
      KEY='ID');

-- Denormalize data: joining facts (orders) with the dimension (customer)
CREATE STREAM ORDERS_ENRICHED AS
    SELECT  O.order_id AS order_id,
            O.item AS item,
            O.order_total_usd AS order_total_usd,
            C.first_name || ' ' || C.last_name AS full_name,
            C.email AS email
    FROM    ORDERS O
            LEFT JOIN
            CUSTOMERS C
            ON O.customer_id = C.id;
