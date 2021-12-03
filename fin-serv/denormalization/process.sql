-- Stream of user orders:
CREATE STREAM orders (
  order_id BIGINT,
  customer_id BIGINT,
  item VARCHAR,
  order_total_usd DECIMAL(10,2)
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
CREATE TABLE customers (
  id BIGINT PRIMARY KEY,
  first_name VARCHAR,
  last_name VARCHAR,
  email VARCHAR
) WITH (
  KAFKA_TOPIC = 'CUST_RAW_STREAM',
  VALUE_FORMAT = 'JSON',
  PARTITIONS = 6
);

-- Denormalize data: joining facts (orders) with the dimension (customer)
CREATE STREAM orders_enriched AS
  SELECT
    c.id AS customer_id,
    o.order_id AS order_id,
    o.item AS item,
    o.order_total_usd AS order_total_usd,
    CONCAT(CONCAT(c.first_name , ' ') , c.last_name) AS full_name,
    c.email AS email
  FROM orders o
    LEFT JOIN customers c
    ON o.customer_id = c.id;
