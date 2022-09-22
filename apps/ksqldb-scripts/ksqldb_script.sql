CREATE STREAM stream_movements (id STRING, card STRING, amount DECIMAL(5,2), origin INTEGER, site STRING, device STRING, createdAt STRING)
WITH (KAFKA_TOPIC = 'movements', VALUE_FORMAT = 'JSON');





CREATE STREAM stream_movements_online
WITH (KAFKA_TOPIC = 'movements_online',TIMESTAMP = 'createdAt', TIMESTAMP_FORMAT='yyyy-MM-dd HH:mm:ss z')
AS SELECT * FROM stream_movements WHERE ORIGIN = 3 PARTITION BY CARD;

CREATE TABLE table_movements_online AS
  SELECT CARD, AS_VALUE(CARD) AS CARD_NUMBER, COUNT(ID) as num_movements, SUM(AMOUNT) as total_amount, 'ONLINE' as description, COLLECT_SET("ID") as movements, COLLECT_SET("DEVICE") as devices, COLLECT_SET("SITE") as sites
  FROM stream_movements_online
WINDOW SESSION (60 seconds)
GROUP BY CARD
EMIT FINAL;

CREATE STREAM stream_possible_fraud_movements_online (CARD_NUMBER STRING, TOTAL_AMOUNT DECIMAL(5,2), NUM_MOVEMENTS INTEGER, MOVEMENTS ARRAY<String>, DEVICES ARRAY<STRING>, SITES ARRAY<STRING>, DESCRIPTION STRING)
WITH (KAFKA_TOPIC = 'TABLE_MOVEMENTS_ONLINE', VALUE_FORMAT = 'JSON');

CREATE STREAM stream_fraud_movements_online
WITH (KAFKA_TOPIC = 'fraud-cases')
AS SELECT * FROM stream_possible_fraud_movements_online WHERE total_amount > 200 AND num_movements > 3;





CREATE STREAM stream_movements_physical
WITH (KAFKA_TOPIC = 'movements_physical',TIMESTAMP = 'createdAt', TIMESTAMP_FORMAT='yyyy-MM-dd HH:mm:ss z')
AS SELECT * FROM stream_movements WHERE ORIGIN != 3 PARTITION BY CARD;

CREATE TABLE table_movements_physical AS
  SELECT CARD, AS_VALUE(CARD) AS CARD_NUMBER, COUNT(ID) as num_movements, SUM(AMOUNT) as total_amount, 'PHYSICAL' as description, COLLECT_SET("ID") as movements, COLLECT_SET("DEVICE") as devices, COLLECT_SET("SITE") as sites
  FROM stream_movements_physical
WINDOW SESSION (60 seconds)
GROUP BY CARD
EMIT FINAL;

CREATE STREAM stream_possible_fraud_movements_physical (CARD_NUMBER STRING, TOTAL_AMOUNT DECIMAL(5,2), NUM_MOVEMENTS INTEGER, MOVEMENTS ARRAY<String>, DEVICES ARRAY<STRING>, SITES ARRAY<STRING>, DESCRIPTION STRING)
WITH (KAFKA_TOPIC = 'TABLE_MOVEMENTS_PHYSICAL', VALUE_FORMAT = 'JSON');

CREATE STREAM stream_fraud_movements_physical
WITH (KAFKA_TOPIC = 'fraud-cases')
AS SELECT * FROM stream_possible_fraud_movements_physical WHERE ARRAY_LENGTH(DEVICES) > 1 OR num_movements > 4;
