-- Create stream of alarms
CREATE STREAM alarms (
  device_id STRING key,
  alarm_name STRING,
  code INT
) WITH (
  VALUE_FORMAT='json',
  KAFKA_TOPIC='alarms',
  PARTITIONS = 6);

-- Create stream filter where code != 0
CREATE STREAM alarms_table AS
  SELECT
    device_id,
    alarm_name,
    code
  FROM alarms
  GROUP BY device_id
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
  FROM throughputs
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
  LEFT JOIN alarms a ON t.device_id = a.device_id;
