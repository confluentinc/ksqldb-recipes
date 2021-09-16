-- Stream of transactions
CREATE SOURCE CONNECTOR transactions WITH (
  'connector.class'          = 'OracleDatabaseSource',
  'name'                     = 'confluent-oracle-source',
  'connector.class'          = 'OracleDatabaseSource',
  'kafka.api.key'            = '<my-kafka-api-key>',
  'kafka.api.secret'         = '<my-kafka-api-secret>',
  'topic.prefix'             = 'oracle_',
  'connection.host'          = '<my-database-endpoint>',
  'connection.port'          = '1521',
  'connection.user'          = '<database-username>',
  'connection.password'      = '<database-password>',
  'db.name'                  = '<db-name>',
  'table.whitelist'          = 'TRANSACTIONS',
  'timestamp.column.name'    = 'created_at',
  'output.data.format'       = 'JSON',
  'db.timezone'              = 'UCT',
  'tasks.max'                = '1');

-- Stream of customers
CREATE SOURCE CONNECTOR customers WITH (
  'connector.class'          = 'OracleDatabaseSource',
  'name'                     = 'confluent-oracle-source',
  'connector.class'          = 'OracleDatabaseSource',
  'kafka.api.key'            = '<my-kafka-api-key>',
  'kafka.api.secret'         = '<my-kafka-api-secret>',
  'topic.prefix'             = 'oracle_',
  'connection.host'          = '<my-database-endpoint>',
  'connection.port'          = '1521',
  'connection.user'          = '<database-username>',
  'connection.password'      = '<database-password>',
  'db.name'                  = '<db-name>',
  'table.whitelist'          = 'CUSTOMERS',
  'timestamp.column.name'    = 'created_at',
  'output.data.format'       = 'JSON',
  'db.timezone'              = 'UCT',
  'tasks.max'                = '1');
