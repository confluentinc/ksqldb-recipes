Confluent Cloud offers pre-built, fully managed connectors that make it easy to instantly connect to popular data sources and end systems in the cloud.
This recipe shows one example of a data source, but you can substitute your own preferred connector to use any data source.
The principles are the same, just modify the connector configuration shown below to fit your deployment (see [documentation](https://docs.confluent.io/cloud/current/connectors/index.html)).

To run a fully-managed connector to write the data into Kafka topics, use Confluent Cloud Console or [Confluent CLI](https://docs.confluent.io/confluent-cli/current/overview.html) command `confluent connect create --config <file>`, submit each connector separately.
