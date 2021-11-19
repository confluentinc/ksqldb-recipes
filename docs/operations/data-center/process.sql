-- Create a Table for the captured tenant occupancy events
CREATE TABLE tenant_occupancy (
  tenant_id VARCHAR PRIMARY KEY,
  customer_id BIGINT
) WITH (
  KAFKA_TOPIC='tenant-occupancy',
  PARTITIONS=3,
  VALUE_FORMAT='JSON'
);

-- Create a Stream for the power control panel telemetry data.
--   tenant_kwh_usage is reset by the device every month
CREATE STREAM panel_power_readings (
  panel_id BIGINT,
  tenant_id VARCHAR,
  panel_current_utilization DOUBLE,
  tenant_kwh_usage BIGINT
) WITH (
  KAFKA_TOPIC='panel-readings',
  PARTITIONS=3,
  VALUE_FORMAT='JSON'
);

-- Create a filtered Stream of panel readings registering power usage >= 85%
--  good for determining panels which are drawing a high electrical load
CREATE STREAM overloaded_panels AS 
  SELECT panel_id, tenant_id, panel_current_utilization 
    FROM PANEL_POWER_READINGS 
    WHERE panel_current_utilization >= 0.85
  EMIT CHANGES;

-- Create a stream of billable power events 
--  
CREATE STREAM billable_power AS 
SELECT 
  FORMAT_TIMESTAMP(FROM_UNIXTIME(panel_power_readings.ROWTIME), 'yyyy-MM') AS billable_month,
  tenant_occupancy.customer_id,
  tenant_occupancy.tenant_id, 
  panel_power_readings.tenant_kwh_usage
FROM PANEL_POWER_READINGS 
INNER JOIN TENANT_OCCUPANCY ON panel_power_readings.tenant_id = tenant_occupancy.tenant_id
EMIT CHANGES;
