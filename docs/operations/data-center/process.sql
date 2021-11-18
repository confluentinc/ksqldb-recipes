-- Create the stream for the captured tenant occupancy events
CREATE STREAM tenant_occupancy (
  tenant_id BIGINT,
  customer_id BIGINT,
  data_center_id VARCHAR
) WITH (
  KAFKA_TOPIC='tenant-occupancy',
  VALUE_FORMAT='JSON',
  PARTITIONS=3
);

-- Create the stream for the power control panel telemetry data
CREATE STREAM panel_readings (
  panel_id BIGINT,
  tenant_id BIGINT,
  data_center_id VARCHAR,
  reading DOUBLE
) WITH (
  KAFKA_TOPIC='panel-readings',
  VALUE_FORMAT='JSON',
  PARTITIONS=3
);

