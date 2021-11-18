
INSERT INTO tenant_occupancy (tenant_id, customer_id, data_center_id) VALUES (12, 924, 'dc:eqix:us:chi1');
INSERT INTO tenant_occupancy (tenant_id, customer_id, data_center_id) VALUES (10, 243, 'dc:eqix:us:chi1');
INSERT INTO tenant_occupancy (tenant_id, customer_id, data_center_id) VALUES (15, 924, 'dc:kddi:eu:ber1');
INSERT INTO tenant_occupancy (tenant_id, customer_id, data_center_id) VALUES (20, 123, 'dc:kddi:eu:ber1');
INSERT INTO tenant_occupancy (tenant_id, customer_id, data_center_id) VALUES (11, 243, 'dc:kddi:cn:hnk2');

INSERT INTO panel_readings (panel_id, tenant_id, data_center_id, reading) VALUES (1, 12, 'dc:eqix:us:chi1', 1.35);
INSERT INTO panel_readings (panel_id, tenant_id, data_center_id, reading) VALUES (2, 10, 'dc:eqix:us:chi1', 0.85);
INSERT INTO panel_readings (panel_id, tenant_id, data_center_id, reading) VALUES (1, 15, 'dc:kddi:eu:ber1', 0.54);
INSERT INTO panel_readings (panel_id, tenant_id, data_center_id, reading) VALUES (2, 20, 'dc:kddi:eu:ber1', 0.67);
INSERT INTO panel_readings (panel_id, tenant_id, data_center_id, reading) VALUES (1, 11, 'dc:kddi:cn:hnk2', 1.21);
