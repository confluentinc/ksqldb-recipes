--
CREATE STREAM...

--
CREATE TABLE...

-- Denormalize data: joining facts (orders) with the dimension (customer)
CREATE STREAM ORDERS_ENRICHED AS
    SELECT  O.order_id AS order_id,
            O.item AS item,
            O.order_total_usd AS order_total_usd,
            C.first_name || ' ' || C.last_name AS full_name,
            C.email AS email,
            C.company AS company,
            C.street_address AS street_address,
            C.city AS city,
            C.country AS country
    FROM    ORDERS O
            LEFT JOIN
            CUSTOMERS C
            ON O.customer_id = C.id;
