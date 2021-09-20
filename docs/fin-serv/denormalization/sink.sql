-- Send data to Snowflake
CREATE SINK CONNECTOR analyzed_clickstream WITH (
  'connector.class'          = 'SnowflakeSink',
  'name'                     = 'snowflake-connector',
  'kafka.api.key'            = '<my-kafka-api-key>',
  'kafka.api.secret'         = '<my-kafka-api-secret>',
  'topics'                   = '<topic1>, <topic2>',
  'input.data.format'        = 'JSON',
  'snowflake.url.name'       = 'https=//wm83168.us-central1.gcp.snowflakecomputing.com=443',
  'snowflake.user.name'      = '<login-username>',
  'snowflake.private.key'    = '<private-key>',
  'snowflake.database.name'  = '<database-name>',
  'snowflake.schema.name'    = '<schema-name>',
  'tasks.max'                = '1');
