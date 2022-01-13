SET 'auto.offset.reset' = 'earliest';

CREATE STREAM mq_transactions (
  dep_account_no STRING,
  dep_balance_dollars BIGINT,
  dep_balance_cents BIGINT,
  timestamp BIGINT
) WITH (
  KAFKA_TOPIC = 'mq_transactions',
  VALUE_FORMAT = 'JSON',
  PARTITIONS = 6
);

CREATE TABLE balance_cache WITH (KAFKA_TOPIC = 'balance_cache') AS SELECT
  dep_account_no,
  CAST(CONCAT(CAST(dep_balance_dollars AS STRING),'.',CAST(dep_balance_cents AS STRING)) AS DOUBLE) AS BALANCE,
  timestamp AS ts_stream, 
  UNIX_TIMESTAMP() AS ts_cache,
  (UNIX_TIMESTAMP() - timestamp) AS ts_delta
FROM mq_transactions
EMIT CHANGES;
