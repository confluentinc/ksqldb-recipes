SET 'auto.offset.reset' = 'earliest';

CREATE TABLE sales_totals AS
  SELECT
    user_id,
    SUM(price) AS total,
    CASE
      WHEN SUM(price) > 400 THEN 'GOLD'
      WHEN SUM(price) > 300 THEN 'SILVER'
      WHEN SUM(price) > 200 THEN 'BRONZE'
      ELSE 'CLIMBING'
    END AS reward_level
  FROM enriched_purchases
  GROUP BY user_id;

CREATE TABLE caffeine_index AS
  SELECT
    user_id,
    count(*) as total,
    (count(*) % 6) AS sequence,
    (count(*) % 6) = 5 AS next_one_free
  FROM purchases
  WHERE product_id = 'coffee'
  GROUP BY user_id;

CREATE TABLE promotion_french_poodle
  AS
  SELECT
      user_id,
      collect_set(product_id) AS products,
      'french_poodle' AS promotion_name
  FROM purchases
  WHERE product_id IN ('dog', 'beret')
  GROUP BY user_id
  HAVING ARRAY_CONTAINS( collect_set(product_id), 'dog' )
  AND ARRAY_CONTAINS( collect_set(product_id), 'beret' )
  EMIT changes;

CREATE TABLE promotion_loose_leaf AS
  SELECT
      user_id,
      collect_set(product_id) AS products,
      'loose_leaf' AS promotion_name
  FROM enriched_purchases
  WHERE product_id IN ('coffee', 'tea')
  GROUP BY user_id
  HAVING ARRAY_CONTAINS( collect_set(product_id), 'coffee' )
  AND NOT ARRAY_CONTAINS( collect_set(product_id), 'tea' )
  AND sum(price) > 20;
