---------------------------------------------------------------------------------------------------
-- Create stream of inventory
---------------------------------------------------------------------------------------------------
CREATE STREAM inventory_stream (
        id STRING key,
        item STRING,
        quantity INTEGER,
        price DOUBLE)
   with (VALUE_FORMAT='json',
         KAFKA_TOPIC='inventory');

---------------------------------------------------------------------------------------------------
-- Create stateful table with up-to-date information of inventory availability
---------------------------------------------------------------------------------------------------
CREATE TABLE inventory_stream_table
	WITH (kafka_topic='inventory_table') AS
	SELECT
		item,
		SUM(quantity) AS item_quantity
	FROM
		inventory_stream
	GROUP BY
		item
        EMIT CHANGES;
