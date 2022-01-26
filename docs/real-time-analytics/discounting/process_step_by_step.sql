-- Application logic, step by step

-- 1. Enrich the orders stream with discount details.
--    Compute the discount amount as well as order total.
CREATE STREAM ORDERS_ENRICHED WITH (
    KAFKA_TOPIC = 'orders_enriched',
    VALUE_FORMAT = 'JSON',
    PARTITIONS = 6
) AS 
SELECT 
    OS.ID AS ORDER_ID,
    OS.DISCOUNT_CODE,
    DISCOUNT_CODES.PERCENTAGE,
    OS.ITEM_CT,
    OS.ORDER_SUBTOTAL, 
    OS.ORDER_SUBTOTAL * (100 - DISCOUNT_CODES.PERCENTAGE) / 100.0 AS ORDER_TOTAL,
    OS.ORDER_SUBTOTAL * (DISCOUNT_CODES.PERCENTAGE / 100.0) AS DISCOUNT_TOTAL
FROM ORDER_STREAM AS OS 
INNER JOIN DISCOUNT_CODES
ON OS.DISCOUNT_CODE = DISCOUNT_CODES.CODE
EMIT CHANGES;

-- 2. Compute aggregates based on discount percentage.
CREATE TABLE DISCOUNT_ANALYSIS WITH (
    KAFKA_TOPIC = 'discount_analysis',
    VALUE_FORMAT = 'JSON',
    PARTITIONS = 6
) AS 
SELECT
    PERCENTAGE,
    ROUND(AVG(ITEM_CT), 0) AS AVG_ITEM_CT,
    ROUND(AVG(ORDER_SUBTOTAL), 2) AS AVG_ORDER_SUBTOTAL,
    ROUND(AVG(ORDER_TOTAL), 2) AS AVG_ORDER_TOTAL,
    ROUND(AVG(DISCOUNT_TOTAL), 2) AS AVG_DISCOUNT_TOTAL
FROM ORDERS_ENRICHED
GROUP BY PERCENTAGE
EMIT CHANGES;