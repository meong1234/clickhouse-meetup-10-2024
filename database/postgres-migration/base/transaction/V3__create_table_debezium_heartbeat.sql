CREATE TABLE IF NOT EXISTS debezium_heartbeat (id SERIAL PRIMARY KEY, ts TIMESTAMP WITH TIME ZONE);

ALTER TABLE debezium_heartbeat REPLICA IDENTITY FULL;