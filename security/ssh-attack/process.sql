-- Define Kafka parameters
DEFINE topic = 'syslog';

-- Extract relevant fields from log messages
CREATE OR REPLACE STREAM `syslog` WITH (
  KAFKA_TOPIC = '${topic}',
  VALUE_FORMAT = 'avro'
);

CREATE STREAM `by_facility` AS
  SELECT TIMESTAMPTOSTRING(TIMESTAMP, 'yyyy-MM-dd HH:mm:ss') AS SYSLOG_TIMESTAMP,
         HOST,
         FACILITY,
         MESSAGE,
         REMOTEADDRESS         
  FROM `syslog`
  PARTITION BY FACILITY
  EMIT CHANGES;

-- Flag events with invalid users, and enrich with a new field 'FACILITY_DESCRIPTION'
CREATE STREAM `invalid_users` AS
  SELECT SYSLOG_TIMESTAMP,
         HOST,
         FACILITY,
         MESSAGE, 
         REMOTEADDRESS,
         CASE WHEN FACILITY = 0 THEN 'kernel messages'
              WHEN FACILITY = 1 THEN 'user-level messages'
              WHEN FACILITY = 2 THEN 'mail system'
              WHEN FACILITY = 3 THEN 'system daemons'
              WHEN FACILITY = 4 THEN 'security/authorization messages'
              WHEN FACILITY = 5 THEN 'messages generated internally by syslogd'
              WHEN FACILITY = 6 THEN 'line printer subsystem'
              ELSE '<unknown>'
         END AS FACILITY_DESCRIPTION
  FROM `by_facility`
  WHERE MESSAGE LIKE 'Invalid user%'
  EMIT CHANGES;

-- Create actionable stream of SSH attacks, enriched with user and IP
CREATE STREAM `ssh_attacks` AS 
  SELECT SYSLOG_TIMESTAMP,
         HOST,
         FACILITY_DESCRIPTION,
         SPLIT(REPLACE(MESSAGE,'Invalid user ',''),' from ')[1] AS ATTACK_USER, 
         SPLIT(REPLACE(MESSAGE,'Invalid user ',''),' from ')[2] AS ATTACK_IP 
  FROM `invalid_users`
  EMIT CHANGES;
