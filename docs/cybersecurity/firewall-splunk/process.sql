SET 'auto.offset.reset' = 'earliest';

CREATE STREAM splunk (
  event VARCHAR,
  time BIGINT,
  host VARCHAR,
  source VARCHAR,
  index VARCHAR,
  sourcetype VARCHAR
) WITH (
  KAFKA_TOPIC = 'splunk-s2s-events',
  VALUE_FORMAT = 'json',
  PARTITIONS = 6
);

-- Split message into array
CREATE STREAM splunk_parsed WITH (KAFKA_TOPIC = 'splunk_parsed') AS SELECT
  *, 
  REGEXP_SPLIT_TO_ARRAY(event, ' ')
FROM splunk
EMIT CHANGES;

-- Filter messages for Cisco ASA and action is Deny
CREATE STREAM splunk_filtered WITH (KAFKA_TOPIC = 'splunk_filtered') AS SELECT
  sourcetype,
  KSQL_COL_0[2] AS action,
  KSQL_COL_0[3] AS protocol,
  REGEXP_SPLIT_TO_ARRAY(KSQL_COL_0[5], 'inside:')[2] as inside,
  REGEXP_SPLIT_TO_ARRAY(KSQL_COL_0[7], 'outside:')[2] as outside
FROM splunk_parsed
WHERE sourcetype = 'cisco:asa' and KSQL_COL_0[2] = 'Deny'
EMIT CHANGES;
