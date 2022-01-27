SET 'auto.offset.reset' = 'earliest';

-- Create stream of predictions
CREATE STREAM PREDICTED_WEIGHT(
  "Fish_Id" VARCHAR KEY,
  "Species" VARCHAR,
  "Height" DOUBLE,
  "Length" DOUBLE,
  "Prediction" DOUBLE
  )
WITH(
  KAFKA_TOPIC = 'kt.mdb.weight-prediction', 
  VALUE_FORMAT = 'JSON'
);

-- Create stream of actual weights
CREATE STREAM ACTUAL_WEIGHT(
  "Fish_Id" VARCHAR KEY,
  "Species" VARCHAR,
  "Weight" DOUBLE
  )
WITH(
  KAFKA_TOPIC = 'kt.mdb.machine-weight', 
  VALUE_FORMAT = 'JSON'
);

-- Create stream joining predictions with actual weights
CREATE STREAM DIFF_WEIGHT
WITH(
  KAFKA_TOPIC = 'weight-diff', 
  VALUE_FORMAT = 'JSON'
)
AS SELECT
   'Key' AS "Key",
   PREDICTED_WEIGHT."Fish_Id" AS "Fish_Id",
   PREDICTED_WEIGHT."Species" AS "Species",
   PREDICTED_WEIGHT."Length" AS "Length",
   PREDICTED_WEIGHT."Height" AS "Height",
   PREDICTED_WEIGHT."Prediction" AS "PredictedWeight",
   ACTUAL_WEIGHT."Weight" AS "ActualWeight",
   ROUND(ABS(PREDICTED_WEIGHT."Prediction" - ACTUAL_WEIGHT."Weight") / ACTUAL_WEIGHT."Weight", 3) AS "Error"
FROM PREDICTED_WEIGHT
INNER JOIN ACTUAL_WEIGHT
WITHIN 1 MINUTE
ON PREDICTED_WEIGHT."Fish_Id" = ACTUAL_WEIGHT."Fish_Id";

-- Create table of one minute aggregates with over 15% error rate
set 'ksql.suppress.enabled'='true';
CREATE TABLE RETRAIN_WEIGHT
WITH(
  KAFKA_TOPIC = 'weight-retrain', 
  VALUE_FORMAT = 'JSON'
)
AS SELECT
   "Key",
   COLLECT_SET("Species") AS "Species",
   EARLIEST_BY_OFFSET("Fish_Id") AS "Fish_Id_Start",
   LATEST_BY_OFFSET("Fish_Id") AS "Fish_Id_End",
   AVG("Error") AS "ErrorAvg"
   FROM DIFF_WEIGHT
   WINDOW TUMBLING (SIZE 1 MINUTE)
   GROUP BY "Key"
   HAVING AVG("Error") > 0.15
   EMIT FINAL;
