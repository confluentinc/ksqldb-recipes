-- Register the initial streams and tables from the Kafka topics
CREATE STREAM PAYMENTS (
  PAYMENT_ID INTEGER KEY,
  CUSTID INTEGER,
  ACCOUNTID INTEGER,
  AMOUNT INTEGER,
  BANK VARCHAR
) WITH (
  kafka_topic='Payment_Instruction',
  value_format='json'
);

create stream aml_status (
  PAYMENT_ID INTEGER,
  BANK VARCHAR,
  STATUS VARCHAR
) with (
  kafka_topic='AML_Status',
  value_format='json'
);

create stream funds_status (
  PAYMENT_ID INTEGER,
  REASON_CODE VARCHAR,
  STATUS VARCHAR
) with (
  kafka_topic='Funds_Status',
  value_format='json'
);

create table customers (
  ID INTEGER PRIMARY KEY, 
  FIRST_NAME VARCHAR, 
  LAST_NAME VARCHAR, 
  EMAIL VARCHAR, 
  GENDER VARCHAR, 
  STATUS360 VARCHAR
) WITH (
  kafka_topic='CUSTOMERS_FLAT',
  value_format='JSON'
);

-- Enrich Payments stream with Customers table
create stream enriched_payments as select
  p.payment_id as payment_id,
  p.custid as customer_id,
  p.accountid,
  p.amount,
  p.bank,
  c.first_name,
  c.last_name,
  c.email,
  c.status360
  from payments p left join customers c on p.custid = c.id;

-- Combine the status streams
CREATE STREAM payment_statuses AS SELECT payment_id, status, 'AML' as source_system FROM aml_status;
INSERT INTO payment_statuses SELECT payment_id, status, 'FUNDS' as source_system FROM funds_status;

-- Combine payment and status events in 1 hour window. Why we need a timing window for stream-stream join?
CREATE STREAM payments_with_status AS SELECT
  ep.payment_id as payment_id,
  ep.accountid,
  ep.amount,
  ep.bank,
  ep.first_name,
  ep.last_name,
  ep.email,
  ep.status360,
  ps.status,
  ps.source_system
  FROM enriched_payments ep LEFT JOIN payment_statuses ps WITHIN 1 HOUR ON ep.payment_id = ps.payment_id ;

-- Aggregate data to the final table
CREATE TABLE payments_final AS SELECT
  payment_id,
  histogram(status) as status_counts,
  collect_list('{ "system" : "' + source_system + '", "status" : "' + STATUS + '"}') as service_status_list
  from payments_with_status
  where status is not null
  group by payment_id;
