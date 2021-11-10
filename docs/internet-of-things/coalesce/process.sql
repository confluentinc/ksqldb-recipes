-- Create stream of alarms
CREATE STREAM alarms (
  device_id STRING key,
  alarm_name STRING,
  code INT
) WITH (
  VALUE_FORMAT='json',
  KAFKA_TOPIC='alarms',
  PARTITIONS = 6);

-- Create stateful table with up-to-date alarms, filter where code != 0
CREATE TABLE alarms_table AS
  SELECT *
  FROM alarms
  GROUP BY alarm_name
  WHERE code IS NOT 0 
  EMIT CHANGES;

-- Create stream of throughputs 
CREATE STREAM throughputs (
  device_id STRING key,
  throughput DOUBLE
) WITH (
  VALUE_FORMAT='json',
  KAFKA_TOPIC='throughputs',
  PARTITIONS = 6);

-- Create stream of throughputs less than threshold 1000.0
CREATE STREAM throughput_insufficient AS
  SELECT *
  FROM alarms
  GROUP BY device_id
  WHERE throughput < 1000.0
  EMIT CHANGES;

-- Combine streams
CREATE STREAM critical_issues_to_investigate AS
  SELECT
    t.device_id,
    t.throughput,
    a.alarm_name,
    a.code
  FROM throughput_insufficient t
  LEFT JOIN alarms a ON t.device_id = f.device_id;
