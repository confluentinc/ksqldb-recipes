-- Stream of user orders:
CREATE STREAM orders (
  order_id BIGINT,
  customer_id BIGINT,
  item VARCHAR,
  order_total_usd NUMERIC(10,2)
) WITH (
  KAFKA_TOPIC = 'orders',
  VALUE_FORMAT = 'json',
  PARTITIONS = 6
);

-- Register the existing stream of customer data
CREATE STREAM cust_raw_stream (
  id BIGINT,
  first_name VARCHAR,
  last_name VARCHAR,
  email VARCHAR
) WITH (
  KAFKA_TOPIC = 'customers',
  VALUE_FORMAT = 'JSON',
  PARTITIONS = 6
);

-- Register the customer data topic as a table
CREATE TABLE customer (
  id BIGINT PRIMARY KEY
) WITH (
  KAFKA_TOPIC = 'CUST_RAW_STREAM',
  VALUE_FORMAT = 'JSON',
  PARTITIONS = 6
);

-- Denormalize data: joining facts (orders) with the dimension (customer)
CREATE STREAM orders_enriched AS
  SELECT
    o.order_id AS order_id,
    o.item AS item,
    o.order_total_usd AS order_total_usd,
    c.first_name || ' ' || C.last_name AS full_name,
    c.email AS email
  FROM orders o
    LEFT JOIN customers c
    ON o.customer_id = c.id;
