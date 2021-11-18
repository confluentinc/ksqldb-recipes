-- Summarize products.
CREATE TABLE all_products AS
  SELECT
    product_id,
    LATEST_BY_OFFSET(category) AS category,
    LATEST_BY_OFFSET(CAST(price AS DOUBLE)) as price
  FROM products
  GROUP BY product_id;

-- Enrich purchases.
CREATE STREAM enriched_purchases AS
  SELECT
    purchases.user_id,
    purchases.product_id AS product_id,
    all_products.category,
    all_products.price
  FROM purchases
    LEFT JOIN all_products ON purchases.product_id = all_products.product_id;
