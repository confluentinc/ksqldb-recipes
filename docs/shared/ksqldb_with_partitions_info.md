---
**NOTE:**
The `KAFKA_TOPIC` property is required, and indicates the topic that will back the stream. The topic must either exist in Kafka, or the `PARTITIONS` property must be provided as well. If you're creating a stream for a topic that already exists, like would be the case when using a connector to source event data, you should remove the `PARTITIONS` property from this command.
---
