Confluent Cloud offers pre-built, fully managed connectors that make it easy to quickly connect to popular data sources and end systems in the cloud.
This recipe shows some example data sources, but you can substitute your own connectors to connect to any supported data source.
The principles are the same, just modify the connector configuration shown below to fit your situation (see [documentation](https://docs.confluent.io/cloud/current/connectors/index.html)).

To run a fully managed connector to source data into Kafka, use the Confluent Cloud Console or [Confluent CLI](https://docs.confluent.io/confluent-cli/current/overview.html) command `confluent connect create --config <file>`. Each connector must be created separately.
