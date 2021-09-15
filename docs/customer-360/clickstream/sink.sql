-- Send data to Elasticsearch
CREATE SINK CONNECTOR analyzed_clickstream WITH (
  'connector.class'          = 'ElasticsearchSink',
  'name'                     = 'elasticsearch-connector',
  'input.data.format'        = 'JSON',
  'kafka.api.key'            = '<my-kafka-api-key>',
  'kafka.api.secret'         = '<my-kafka-api-secret>',
  'topics'                   = 'USER_IP_ACTIVITY, ENRICHED_ERROR_CODES_COUNT',
  'connection.url'           = '<elasticsearch-URI>',
  'connection.user'          = '<elasticsearch-username>',
  'connection.password'      = '<elasticsearch-password>',
  'type.name'                = 'type.name=kafkaconnect',
  'key.ignore'               = 'true',
  'schema.ignore'            = 'true'
);
