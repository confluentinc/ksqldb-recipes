CREATE SINK CONNECTOR training-data WITH (
    'connector.class'          = 'MongoDbAtlasSink',
    'name'                     = 'weight-data', 
    'kafka.auth.mode'          = 'KAFKA_API_KEY',
    'kafka.api.key'            = '<my-kafka-api-key',
    'kafka.api.secret'         = '<my-kafka-api-secret>',
    'input.data.format'        = 'JSON',
    'connection.host'          = '<database-host-address>',
    'connection.user'          = '<my-username>',
    'connection.password'      = '<my-password>',
    'topics'                   = 'weight-diff',
    'max.num.retries'          = '3',
    'retries.defer.timeout'    = '5000',
    'max.batch.size'           = '0',
    'database'                 = 'mdb',
    'collection'               = 'training-data',
    'tasks.max'                = '1'
);     

CREATE SINK CONNECTOR retraining-trigger WITH (
    'connector.class'      = 'HttpSink',
    'input.data.format'    = 'JSON',
    'name'                 = 'retrain-trigger',
    'kafka.auth.mode'      = 'KAFKA_API_KEY',
    'kafka.api.key'        = '<my-kafka-api-key>',
    'kafka.api.secret'     = '<my-kafka-api-secret>',
    'topics'               = 'weight-retrain',
    'tasks.max'            = '1',
    'http.api.url'         = '<training-endpoint-url>',
    'request.method'       = 'POST'
);