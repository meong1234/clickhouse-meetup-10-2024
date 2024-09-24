-- +goose Up
CREATE MATERIALIZED VIEW IF NOT EXISTS iot_battery_last_location_mv
TO iot_battery_last_location
AS
SELECT
    battery_serial,
    latitude AS last_valid_latitude,
    longitude AS last_valid_longitude,
    event_time AS last_event_time
FROM iot_battery_metrics
WHERE latitude IS NOT NULL
  AND longitude IS NOT NULL
  AND latitude <> 0
  AND longitude <> 0;