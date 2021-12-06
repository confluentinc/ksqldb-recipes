-- create stream of locations
CREATE STREAM locations (
  vehicle_id int,
  latitude double,
  longitude double,
  timestamp varchar
) WITH (
  KAFKA_TOPIC = 'locations',
  VALUE_FORMAT = 'json',
  PARTITIONS = 6
);

-- fleet lookup table
CREATE TABLE fleet (
  vehicle_id int primary key,
  driver_id int,
  license bigint
) WITH (
  KAFKA_TOPIC = 'descriptions',
  VALUE_FORMAT = 'json',
  PARTITIONS = 6
);

-- enrich fleet location stream with more fleet information
CREATE STREAM fleet_location_enhanced AS
  SELECT
    l.vehicle_id,
    latitude,
    longitude,
    timestamp,
    f.driver_id,
    f.license
  FROM locations l
  LEFT JOIN fleet f ON l.vehicle_id = f.vehicle_id;
