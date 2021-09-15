---------------------------------------------------------------------------------------------------
-- Create stateful table with up-to-date information of inventory availability
---------------------------------------------------------------------------------------------------
CREATE TABLE inventory_stream_table
	WITH (kafka_topic='inventory_table') AS
	SELECT
		item,
		SUM(qty) AS item_qty
	FROM
		inventory_stream
	GROUP BY
		item
        EMIT CHANGES;
