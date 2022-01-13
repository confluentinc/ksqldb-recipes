SET 'auto.offset.reset' = 'earliest';

-- Create stream of transactions from the Kafka topic
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

-- Normalize the data and calculate timestamp deltas
CREATE STREAM mq_transactions_normalized WITH (KAFKA_TOPIC = 'mq_transactions_normalized') AS SELECT
  dep_account_no,
  CAST(CONCAT(CAST(dep_balance_dollars AS STRING),'.',CAST(dep_balance_cents AS STRING)) AS DOUBLE) AS BALANCE,
  timestamp AS ts_stream, 
  UNIX_TIMESTAMP() AS ts_cache,
  (UNIX_TIMESTAMP() - timestamp) AS ts_delta
FROM mq_transactions
EMIT CHANGES;

-- Materialize the stream of transactions into a table,
-- like a local cache, that reflects the latest for each dep_account_no
CREATE TABLE mq_cache WITH (KAFKA_TOPIC = 'mq_cache') AS SELECT
  dep_account_no,
  latest_by_offset(BALANCE) AS balance_latest,
  latest_by_offset(ts_stream) AS ts_stream_latest,
  latest_by_offset(ts_cache) AS ts_cache_latest,
  latest_by_offset(ts_delta) AS ts_delta_latest
FROM mq_transactions_normalized
GROUP BY dep_account_no
EMIT CHANGES;
