CREATE SOURCE CONNECTOR customer WITH (
  'connector.class'       = 'MySqlCdcSource',
  'name'                  = 'Customer_Tenant_Source',
  'kafka.api.key'         = '<my-kafka-api-key>',
  'kafka.api.secret'      = '<my-kafka-api-secret>',
  'database.hostname'     = '<db-hostname>',
  'database.port'         = '3306',
  'database.user'         = '<db-user>',
  'database.password'     = '<db-password>',
  'database.server.name'  = 'mysql',
  'database.whitelist'    = 'customer',
  'table.includelist'     = 'customer.tenant',
  'snapshot.mode'         = 'initial',
  'output.data.format'    = 'AVRO',
  'tasks.max'             = '1'
);

CREATE SOURCE CONNECTOR readings WITH (
  'connector.class'       = 'MqttSource',
  'name'                  = 'Smart_Panel_Source',
  'kafka.api.key'         = '<my-kafka-api-key>',
  'kafka.api.secret'      = '<my-kafka-api-secret>',
  'kafka.topic'           = 'panel-readings',
  'mqtt.server.uri'       = 'tcp=//<mqtt-server-hostname>=1881',
  'mqtt.topics'           = '<mqtt-topic>',
  'tasks.max'             = '1'
);
