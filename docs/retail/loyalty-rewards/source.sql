-- Example
CREATE SOURCE CONNECTOR loyalty_rewards WITH (
  'connector.class'          = 'PostgresSource',
  'name'                     = 'recipe-postgres-loyalty-rewards',
  'kafka.api.key'            = '<my-kafka-api-key>',
  'kafka.api.secret'         = '<my-kafka-api-secret>',
  'connection.host'          = '<database-endpoint>',
  'connection.port'          = '<database-endpoint>',
  'connection.user'          = '<database-user>',
  'connection.password'      = '<database-password>',
  'database'                 = '<database-name>',
  'collection'               = '<database-collection-name>',
  'timestamp.column.name'    = 'created_at',
  'output.data.format'       = 'JSON'
  'db.timezone'              = 'UTC',
  'tasks.max'                = '1');
