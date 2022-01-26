CREATE SOURCE CONNECTOR merchant-data-cdc WITH (
  'connector.class'       = 'MySqlCdcSource',
  'name'                  = 'merchant-data-cdc',
  'kafka.api.key'         = '<my-kakfa-api-key>',
  'kafka.api.secret'      = '<my-kafka-api-secret>',
  'database.hostname'     = '<my-database-endpoint>',
  'database.port'         = '3306',
  'database.user'         = '<my-database-user>',
  'database.password'     = '<my-database-password>',
  'database.server.name'  = 'merchant-data-db',
  'database.ssl.mode'     = 'preferred',
  'output.data.format'    = 'JSON',
  'tasks.max'             = '1'
);
