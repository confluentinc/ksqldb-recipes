-- Extract relevant fields from log messages
CREATE STREAM syslog (
  ts varchar, 
  host varchar,
  facility int,
  message varchar,
  remote_address varchar 
) WITH (
  KAFKA_TOPIC = 'syslog',
  VALUE_FORMAT = 'json',
  PARTITIONS = 6
);

-- Flag events with invalid users, and enrich with a new field 'FACILITY_DESCRIPTION'
CREATE STREAM invalid_users AS
  SELECT
    FORMAT_TIMESTAMP(ts, 'yyyy-MM-dd HH:mm:ss') AS syslog_timestamp,
    host,
    facility,
    message, 
    remote_address,
    CASE WHEN facility = 0 THEN 'kernel messages'
         WHEN facility = 1 THEN 'user-level messages'
         WHEN facility = 2 THEN 'mail system'
         WHEN facility = 3 THEN 'system daemons'
         WHEN facility = 4 THEN 'security/authorization messages'
         WHEN facility = 5 THEN 'messages generated internally by syslogd'
         WHEN facility = 6 THEN 'line printer subsystem'
         ELSE '<unknown>'
       END AS facility_description
  FROM syslog 
  WHERE message LIKE 'Invalid user%'
  EMIT CHANGES;

-- Create actionable stream of SSH attacks, enriched with user and IP
CREATE STREAM ssh_attacks AS 
  SELECT
    syslog_timestamp,
    host,
    facility_description,
    SPLIT(REPLACE(message, 'Invalid user ', ''), ' from ')[1] AS attack_user,
    remote_address AS attack_ip
  FROM invalid_users
  EMIT CHANGES;
