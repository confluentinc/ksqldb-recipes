SET 'auto.offset.reset' = 'earliest';

-- Create stream of pages
CREATE STREAM pages (
  time BIGINT,
  page_id STRING KEY,
  page STRING,
  customer INTEGER
) WITH (
  VALUE_FORMAT = 'json',
  KAFKA_TOPIC = 'pages',
  PARTITIONS = 6
);

-- Create stateful table with list of pages visited by each customer
-- Pages are added to an Array using the `COLLECT_LIST` function
CREATE TABLE pages_per_customer WITH (KAFKA_TOPIC = 'pages_per_customer') AS
SELECT
  time,
  customer,
  COLLECT_LIST(page) AS page_list,
  COUNT(*) AS count
FROM pages
GROUP BY customer
EMIT CHANGES;
