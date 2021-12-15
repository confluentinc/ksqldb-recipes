CREATE SOURCE CONNECTOR RabbitMQ WITH (
  'connector.class'          = 'RabbitMQSource',
  'name'                     = 'RabbitMQSource_0',
  'kafka.api.key'            = '<my-kafka-api-key>',
  'kafka.api.secret'         = '<my-kafka-api-secret>',
  'kafka.topic'              = 'from-rabbit'
  'rabbitmq.host'            = '192.168.1.99',
  'rabbitmq.username'        = '<username>',
  'rabbitmq.password'        = '<password>',
  'rabbitmq.queue'           = '<queue-name>',
  'tasks.max'                = '1');
