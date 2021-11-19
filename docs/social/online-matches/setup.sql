CREATE STREAM message_stream (
  send_id BIGINT,
  recv_id BIGINT,
  message VARCHAR
) WITH (
  KAFKA_TOPIC = 'MESSAGE_STREAM',
  VALUE_FORMAT = 'AVRO',
  PARTITIONS = 3
);
