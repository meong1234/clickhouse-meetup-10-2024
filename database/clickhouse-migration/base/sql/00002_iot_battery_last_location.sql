-- +goose Up
CREATE TABLE IF NOT EXISTS iot_battery_last_location
(
    battery_serial LowCardinality(String),
    last_valid_latitude Float64,
    last_valid_longitude Float64,
    last_event_time DateTime64(9)
)
    ENGINE = ReplacingMergeTree(last_event_time)
        ORDER BY battery_serial
        SETTINGS index_granularity = 8192;