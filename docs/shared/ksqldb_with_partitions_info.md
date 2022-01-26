---
**NOTE:**
The `KAFKA_TOPIC` property is required, and indicates the topic that will back the stream. If that topic does not exist in Kafka, you must provide the `PARTITIONS` property as well. If you're creating a stream for a topic that already exists (for example, if you're using a connector to source event data), remove the `PARTITIONS` property from this command.
---
