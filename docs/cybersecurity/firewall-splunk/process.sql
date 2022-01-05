SET 'auto.offset.reset' = 'earliest';

CREATE STREAM splunk (
  event VARCHAR,
  time BIGINT,
  host VARCHAR,
  source VARCHAR,
  sourcetype VARCHAR,
  index VARCHAR
) WITH (
  KAFKA_TOPIC = 'splunk-s2s-events',
  VALUE_FORMAT = 'json',
  PARTITIONS = 6
);

CREATE STREAM cisco_asa AS SELECT
  event,
  source,
  sourcetype,
  index
FROM splunk
WHERE sourcetype = 'cisco:asa'
EMIT CHANGES;

CREATE STREAM firewalls (
  src VARCHAR,
  messageID BIGINT,
  index VARCHAR,
  dest VARCHAR,
  hostname VARCHAR,
  protocol VARCHAR,
  action VARCHAR,
  srcport BIGINT,
  sourcetype VARCHAR,
  destport BIGINT,
  timestamp VARCHAR
) WITH (
  KAFKA_TOPIC = 'firewalls',
  VALUE_FORMAT = 'json',
  PARTITIONS = 6
);

CREATE TABLE aggregator WITH (KAFKA_TOPIC='AGGREGATOR', KEY_FORMAT='JSON', PARTITIONS=6) AS SELECT
  hostname,
  messageID,
  action,
  src,
  dest,
  dest_port,
  sourcetype,
  AS_VALUE(hostname) AS hostname,
  AS_VALUE(messageID) AS messageID,
  AS_VALUE(action) AS action,
  AS_VALUE(src) AS src,
  AS_VALUE(dest) AS dest,
  AS_VALUE(destport) AS dest_port,
  AS_VALUE(sourcetype) AS sourcetype,
  TIMESTAMPTOSTRING(WINDOWSTART, 'yyyy-MM-dd HH:mm:ss', 'UTC') TIMESTAMP,
  300 DURATION,
  COUNT(*) COUNTS
FROM firewalls
WINDOW TUMBLING ( SIZE 300 SECONDS ) 
GROUP BY sourcetype, action, hostname, messageID, src, dest, destport
EMIT CHANGES;

CREATE STREAM FW_DENY WITH (KAFKA_TOPIC='FW_DENY') AS SELECT *
FROM firewalls
WHERE action = 'Deny'
EMIT CHANGES;
