-- stream of user clicks:
CREATE STREAM clickstream (
  _time BIGINT,
  time VARCHAR,
  ip VARCHAR,
  request VARCHAR,
  status INT,
  userid INT,
  bytes BIGINT,
  agent VARCHAR
) WITH (
  KAFKA_TOPIC = 'clickstream',
  VALUE_FORMAT = 'json',
  PARTITIONS = 1
);

-- users lookup table:
CREATE TABLE WEB_USERS (
  user_id VARCHAR PRIMARY KEY,
  registered_At BIGINT,
  username VARCHAR,
  first_name VARCHAR,
  last_name VARCHAR,
  city VARCHAR,
  level VARCHAR
) WITH (
  KAFKA_TOPIC = 'clickstream_users',
  VALUE_FORMAT = 'json',
  PARTITIONS = 1
);

-- Build materialized stream views:

-- enrich click-stream with more user information:
CREATE STREAM USER_CLICKSTREAM AS
  SELECT
    u.user_id,
    u.username,
    ip,
    u.city,
    request,
    status,
    bytes
  FROM clickstream c
  LEFT JOIN web_users u ON cast(c.userid AS VARCHAR) = u.user_id;

-- Build materialized table views:

-- Table of html pages per minute for each user:
CREATE TABLE pages_per_min AS
  SELECT
    userid AS k1,
    AS_VALUE(userid) AS userid,
    WINDOWSTART AS EVENT_TS,
    count(*) AS pages
  FROM clickstream WINDOW HOPPING (SIZE 60 SECOND, ADVANCE BY 5 SECOND)
  WHERE request LIKE '%html%'
  GROUP BY userid;

-- User sessions table - 30 seconds of inactivity expires the session
-- Table counts number of events within the session
CREATE TABLE CLICK_USER_SESSIONS AS
  SELECT
    username AS K,
    AS_VALUE(username) AS username,
    WINDOWEND AS EVENT_TS,
    count(*) AS events
  FROM USER_CLICKSTREAM WINDOW SESSION (30 SECOND)
  GROUP BY username;

-- number of errors per min, using 'HAVING' Filter to show ERROR codes > 400
-- where count > 5
CREATE TABLE ERRORS_PER_MIN_ALERT WITH (KAFKA_TOPIC='ERRORS_PER_MIN_ALERT') AS
  SELECT
    status AS k1,
    AS_VALUE(status) AS status,
    WINDOWSTART AS EVENT_TS,
    count(*) AS errors
  FROM clickstream WINDOW HOPPING (SIZE 60 SECOND, ADVANCE BY 20 SECOND)
  WHERE status > 400
  GROUP BY status
  HAVING COUNT(*) > 5 AND COUNT(*) IS NOT NULL;

-- Enriched user details table:
-- Aggregate (count&groupBy) using a TABLE-Window
CREATE TABLE USER_IP_ACTIVITY WITH (KEY_FORMAT='json', KAFKA_TOPIC='USER_IP_ACTIVITY') AS
  SELECT
    username AS k1,
    ip AS k2,
    city AS k3,
    AS_VALUE(username) AS username,
    WINDOWSTART AS EVENT_TS,
    AS_VALUE(ip) AS ip,
    AS_VALUE(city) AS city,
    COUNT(*) AS count
  FROM USER_CLICKSTREAM WINDOW TUMBLING (SIZE 60 SECOND)
  GROUP BY username, ip, city
  HAVING COUNT(*) > 1;
