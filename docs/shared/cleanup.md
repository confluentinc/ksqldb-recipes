To clean up the resources created by this ksqlDB recipe, use the ksqlDB commands shown below (substitute stream or topic name, as appropriate).
By including the `DELETE TOPIC` clause, the stream or table's source topic is also deleted, asynchronously.

```
DROP STREAM IF EXISTS <stream_name> DELETE TOPIC;
DROP TABLE IF EXISTS <table_name> DELETE TOPIC;
```
