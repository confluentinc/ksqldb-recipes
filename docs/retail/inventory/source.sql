-- Create stream of inventory
CREATE STREAM inventory_stream (
	id STRING key,
	item STRING,
	quantity INTEGER,
	price DOUBLE)
   with (VALUE_FORMAT='json',
         KAFKA_TOPIC='inventory');

-- add some mock data
insert into inventory_stream (id, item, quantity, price) values ('1', 'Apple Magic Mouse 2', 10, 99);
insert into inventory_stream (id, item, quantity, price) values ('2', 'iPhoneX', 25, 999);
insert into inventory_stream (id, item, quantity, price) values ('3', 'MacBookPro13', 100, 1799);
insert into inventory_stream (id, item, quantity, price) values ('4', 'iPad4', 20, 340);
insert into inventory_stream (id, item, quantity, price) values ('5', 'Apple Pencil', 10, 79);
insert into inventory_stream (id, item, quantity, price) values ('5', 'PhoneX', 10, 899);
insert into inventory_stream (id, item, quantity, price) values ('4', 'iPad4', -20, 399);
insert into inventory_stream (id, item, quantity, price) values ('3', 'MacBookPro13', 10, 1899);
insert into inventory_stream (id, item, quantity, price) values ('4', 'iPad4', 20, 399);
