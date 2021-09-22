-- Stream of fleet descriptions
CREATE SOURCE CONNECTOR fleet_description WITH (
  'connector.class'          = 'PostgresSource',
  'name'                     = 'confluent-postgresql-source',
  'kafka.api.key'            = '<my-kafka-api-key>',
  'kafka.api.secret'         = '<my-kafka-api-secret>',
  'topic.prefix'             = 'postgresql_',
  'connection.host'          = '<my-database-endpoint>',
  'connection.port'          = '5432',
  'connection.user'          = 'postgres',
  'connection.password'      = '<my-database-password>',
  'db.name'                  = 'postgres',
  'table.whitelist'          = 'fleet_description',
  'timestamp.column.name'    = 'created_at',
  'output.data.format'       = 'JSON',
  'db.timezone'              = 'UTC',
  'tasks.max'                = '1');

-- Stream of current location of each vehicle in the fleet
CREATE SOURCE CONNECTOR fleet_location WITH (
  'connector.class'          = 'PostgresSource',
  'name'                     = 'confluent-postgresql-source',
  'kafka.api.key'            = '<my-kafka-api-key>',
  'kafka.api.secret'         = '<my-kafka-api-secret>',
  'topic.prefix'             = 'postgresql_',
  'connection.host'          = '<my-database-endpoint>',
  'connection.port'          = '5432',
  'connection.user'          = 'postgres',
  'connection.password'      = '<my-database-password>',
  'db.name'                  = 'postgres',
  'table.whitelist'          = 'fleet_location',
  'timestamp.column.name'    = 'created_at',
  'output.data.format'       = 'JSON',
  'db.timezone'              = 'UTC',
  'tasks.max'                = '1');
