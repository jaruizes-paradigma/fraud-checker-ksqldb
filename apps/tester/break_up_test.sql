CREATE STREAM stream_movements (id STRING, card STRING, amount DECIMAL(5,2), origin INTEGER, site STRING, device STRING, createdAt STRING)
WITH (KAFKA_TOPIC = 'movements', VALUE_FORMAT = 'JSON');

CREATE STREAM stream_movements_online
WITH (KAFKA_TOPIC = 'movements_online',TIMESTAMP = 'createdAt', TIMESTAMP_FORMAT='yyyy-MM-dd HH:mm:ss z')
AS SELECT * FROM stream_movements WHERE ORIGIN = 3 PARTITION BY CARD;