CREATE STREAM users (
  user_id VARCHAR KEY,
  name VARCHAR
) WITH (
  KAFKA_TOPIC = 'USERS',
  VALUE_FORMAT = 'AVRO',
  PARTITIONS = 3
);

CREATE STREAM products (
  product_id VARCHAR KEY,
  category VARCHAR,
  price DECIMAL(10,2)
) WITH (
  KAFKA_TOPIC = 'products',
  VALUE_FORMAT = 'AVRO',
  PARTITIONS = 3
);

CREATE STREAM purchases (
  user_id VARCHAR KEY,
  product_id VARCHAR
) WITH (
  KAFKA_TOPIC = 'purchases',
  VALUE_FORMAT = 'AVRO',
  PARTITIONS = 3
);
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
-- Some users.
INSERT INTO users ( user_id, name ) VALUES ( 'u2001', 'kris' );
INSERT INTO users ( user_id, name ) VALUES ( 'u2002', 'dave' );
INSERT INTO users ( user_id, name ) VALUES ( 'u2003', 'yeva' );
INSERT INTO users ( user_id, name ) VALUES ( 'u2004', 'rick' );

-- Some products.
INSERT INTO products ( product_id, category, price ) VALUES ( 'tea', 'beverages', 2.55 );
INSERT INTO products ( product_id, category, price ) VALUES ( 'coffee', 'beverages', 2.99 );
INSERT INTO products ( product_id, category, price ) VALUES ( 'dog', 'pets', 249.99 );
INSERT INTO products ( product_id, category, price ) VALUES ( 'cat', 'pets', 195.00 );
INSERT INTO products ( product_id, category, price ) VALUES ( 'beret', 'fashion', 34.99 );
INSERT INTO products ( product_id, category, price ) VALUES ( 'handbag', 'fashion', 126.00 );

-- Some purchases.
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'kris', 'coffee' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'kris', 'coffee' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'kris', 'coffee' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'yeva', 'beret' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'yeva', 'coffee' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'yeva', 'cat' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'kris', 'coffee' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'rick', 'tea' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'yeva', 'coffee' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'yeva', 'coffee' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'kris', 'coffee' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'dave', 'dog' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'dave', 'coffee' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'kris', 'coffee' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'kris', 'beret' );

-- A price increase!
INSERT INTO products ( product_id, category, price ) VALUES ( 'coffee', 'beverages', 3.05 );

-- Some more purchases.
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'kris', 'coffee' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'rick', 'coffee' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'yeva', 'coffee' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'kris', 'coffee' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'kris', 'coffee' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'rick', 'dog' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'rick', 'coffee' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'yeva', 'coffee' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'rick', 'cat' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'kris', 'coffee' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'kris', 'coffee' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'kris', 'coffee' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'kris', 'coffee' );
INSERT INTO purchases ( user_id, product_id ) VALUES ( 'yeva', 'handbag' );
