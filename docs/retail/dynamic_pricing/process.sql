-- Create stream of sales
CREATE STREAM sales (
  item_id INT key,
  seller_id STRING,
  price DOUBLE
) WITH (
  VALUE_FORMAT='json',
  KAFKA_TOPIC='sales',
  PARTITIONS = 6);

-- Create table of items
CREATE TABLE items (
  item_id INT PRIMARY key,
  item_name STRING
) WITH (
  VALUE_FORMAT='json',
  KAFKA_TOPIC='items',
  PARTITIONS = 6);

-- Calculate minimum, maximum, and average price, per item, and join with item name
CREATE TABLE sales_stats AS
SELECT S.item_id,
       I.item_name,
       MIN(price) AS price_min,
       MAX(price) AS price_max,
       AVG(price) AS price_avg
FROM sales S
INNER JOIN items I ON S.item_id = I.item_id
GROUP BY S.item_id
EMIT CHANGES;
