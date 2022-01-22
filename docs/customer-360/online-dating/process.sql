SET 'auto.offset.reset' = 'earliest';

CREATE STREAM messages (
  send_id BIGINT,
  recv_id BIGINT,
  message VARCHAR
) WITH (
  KAFKA_TOPIC = 'MESSAGES',
  VALUE_FORMAT = 'AVRO',
  PARTITIONS = 6
);

CREATE STREAM conversations AS
SELECT
  ARRAY_JOIN(ARRAY_SORT(ARRAY [send_id, recv_id]), '<>') AS conversation_id
FROM messages
GROUP BY ARRAY_JOIN(ARRAY_SORT(ARRAY [send_id, recv_id]), '<>')
HAVING
  REDUCE(
    ENTRIES(
        AS_MAP(
          COLLECT_LIST(CAST(rowtime AS STRING)),
          COLLECT_LIST(send_id)
        ),
        true
    ),
    STRUCT(step := 'start', last_sender := CAST(-1 AS BIGINT)),
    (old_state, element) => CASE
      WHEN old_state->step = 'start'
        THEN struct(step := 'opened', last_sender := element->v)
      WHEN old_state->step = 'opened' AND old_state->last_sender != element->v
        THEN struct(step := 'replied', last_sender := element->v)
      WHEN old_state->step = 'replied' AND old_state->last_sender != element->v
        THEN struct(step := 'connected', last_sender := element->v)
      ELSE old_state
    END
  )->step = 'connected'
EMIT CHANGES;
