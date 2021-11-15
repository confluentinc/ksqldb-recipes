-- Create table with latest state of alarms
CREATE TABLE alarms (
  device_id STRING PRIMARY key,
  alarm_name STRING,
  code INT
) WITH (
  VALUE_FORMAT='json',
  KAFKA_TOPIC='alarms',
  PARTITIONS = 6);

-- Create stream of throughputs 
CREATE STREAM throughputs (
  device_id STRING key,
  throughput DOUBLE
) WITH (
  VALUE_FORMAT='json',
  KAFKA_TOPIC='throughputs',
  PARTITIONS = 6);

-- Filter throughputs below threshold 1000.0
CREATE STREAM throughput_insufficient AS
  SELECT *
  FROM throughputs
  WHERE throughput < 1000.0
  EMIT CHANGES;

-- Create new stream where threshold is insufficient and alarm code is not 0
CREATE STREAM critical_issues_to_investigate AS
  SELECT
    t.device_id,
    t.throughput,
    a.alarm_name,
    a.code
  FROM throughput_insufficient t
  LEFT JOIN alarms a ON t.device_id = a.device_id
  WHERE a.code != 0;
