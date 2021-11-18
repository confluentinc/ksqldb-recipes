CREATE STREAM users (
  user_id VARCHAR KEY,
  name VARCHAR
) WITH (
  KAFKA_TOPIC = 'USERS',
  VALUE_FORMAT = 'avro',
  PARTITIONS = 3
);

CREATE STREAM products (
  product_id VARCHAR KEY,
  category VARCHAR,
  price DECIMAL(10,2)
) WITH (
  KAFKA_TOPIC = 'products',
  VALUE_FORMAT = 'avro',
  PARTITIONS = 3
);

CREATE STREAM purchases (
  user_id VARCHAR KEY,
  product_id VARCHAR
) WITH (
  KAFKA_TOPIC = 'purchases',
  VALUE_FORMAT = 'avro',
  PARTITIONS = 3
);
