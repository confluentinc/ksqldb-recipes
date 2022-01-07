SET 'auto.offset.reset' = 'earliest';

-- Create stream of pages
CREATE STREAM pages (
  customer INTEGER,
  time BIGINT,
  page_id STRING,
  page STRING
) WITH (
  VALUE_FORMAT = 'JSON',
  KAFKA_TOPIC = 'pages',
  PARTITIONS = 6
);

-- Create stateful table with list of pages visited by each customer
-- Pages are added to an Array using the `COLLECT_LIST` function
CREATE TABLE pages_per_customer WITH (KAFKA_TOPIC = 'pages_per_customer') AS
SELECT
  customer,
  COLLECT_LIST(page) AS page_list,
  COUNT(*) AS count
FROM pages
GROUP BY customer
EMIT CHANGES;
