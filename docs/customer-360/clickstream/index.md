---
seo:
  title: Understand User Behavior with Clickstream Data 
  description: This ksqlDB recipe processes clickstream data to understand the behavior of its online users.
---

# Understand user behavior with clickstream data

Analyzing clickstream data enables businesses to optimize webpages and determine the effectiveness of their web presence by better understanding their users’ click activity and navigation patterns. Because clickstream data often involves large data volumes, stream processing is a natural fit, as it quickly processes data as soon as it is ingested for analysis. This recipe enables you to measure key statistics on visitor activity over a given time frame, such as how many webpages they are viewing, how long they’re engaging with the website, and more.

![grafana](../../img/clickstream.png)

## Step by step

### Set up your environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

This recipe creates simulated data with the `Datagen` connector.

```json
--8<-- "docs/customer-360/clickstream/source.json"
```

Optional: To simulate a real-world scenario where user sessions aren't just always open but do close after some time, you can pause and resume the `DATAGEN_CLICKSTREAM` connector.

### Run the stream processing app

Now you can process the data in a variety of ways by enriching the clickstream data with user information, analyze errors, aggregate data into windows of time, etc.

--8<-- "docs/shared/ksqlb_processing_intro.md"

```sql
--8<-- "docs/customer-360/clickstream/process.sql"
```

### Write the data out

After processing the data, send it to Elasticsearch.

```json
--8<-- "docs/customer-360/clickstream/sink.json"
```

### Cleanup

--8<-- "docs/shared/cleanup.md"
