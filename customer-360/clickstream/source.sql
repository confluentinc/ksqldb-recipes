-- Stream of HTTP codes
CREATE SOURCE CONNECTOR datagen_clickstream_codes WITH (
  'connector.class'          = 'DatagenSource',
  'kafka.topic'              = 'clickstream_codes',
  'quickstart'               = 'clickstream_codes',
  'maxInterval'              = '20',
  'format'                   = 'json',
  'key.converter'            = 'org.apache.kafka.connect.converters.IntegerConverter');

-- Stream of users
CREATE SOURCE CONNECTOR datagen_clickstream_users WITH (
  'connector.class'          = 'DatagenSource',
  'kafka.topic'              = 'clickstream_users',
  'quickstart'               = 'clickstream_users',
  'maxInterval'              = '10',
  'format'                   = 'json',
  'key.converter'            = 'org.apache.kafka.connect.converters.IntegerConverter');

-- Stream of per-user session information
CREATE SOURCE CONNECTOR datagen_clickstream WITH (
  'connector.class'          = 'DatagenSource',
  'kafka.topic'              = 'clickstream',
  'quickstart'               = 'clickstream',
  'maxInterval'              = '30',
  'format'                   = 'json');
