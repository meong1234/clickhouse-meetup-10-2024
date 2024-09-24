-- +goose Up
CREATE TABLE IF NOT EXISTS iot_battery_metrics
(
    -- Timestamp of the recorded metric in high precision
    `event_time`         DateTime64(9) CODEC (Delta(8), ZSTD(1)) ,

    -- Unique battery serial number (LowCardinality for optimized storage)
    `battery_serial` LowCardinality(String) ,

    -- Location data
    `latitude`           Float64 CODEC (ZSTD(1)),
    `longitude`          Float64 CODEC (ZSTD(1)),

    -- Battery health indicators
    `state_of_charge`    Float64 CODEC (ZSTD(1)) ,
    `state_of_health`    Float64 CODEC (ZSTD(1)) ,
    `charge_cycles`      UInt32 CODEC (ZSTD(1))  ,

    -- Battery electrical data
    `battery_voltage`    Float64 CODEC (ZSTD(1)) ,
    `battery_current`    Float64 CODEC (ZSTD(1)) ,
    `battery_power`      Float64 MATERIALIZED abs((battery_voltage / 1000) * (battery_current / 1000)) ,

    -- Battery cell voltage
    `cell_voltages`      Array(Float64) CODEC (ZSTD(1)) ,
    `min_cell_voltage`   Float64 MATERIALIZED arrayMin(cell_voltages) ,
    `max_cell_voltage`   Float64 MATERIALIZED arrayMax(cell_voltages) ,
    `voltage_difference` Float64 MATERIALIZED (max_cell_voltage - min_cell_voltage) ,

    -- Battery temperature
    `bms_temperature`    Float64 CODEC (ZSTD(1)) ,
    `cell_temperatures`  Array(Float64) CODEC (ZSTD(1)) ,
    `min_cell_temperature` Float64 MATERIALIZED arrayMin(cell_temperatures) ,
    `max_cell_temperature` Float64 MATERIALIZED arrayMax(cell_temperatures),

    INDEX idxevent_time event_time TYPE minmax GRANULARITY 1
)
    ENGINE = MergeTree
        PARTITION BY toDate(event_time) -- Partition by date for optimized time-series queries
        ORDER BY (battery_serial, toUnixTimestamp64Nano(event_time)) -- Ordered by battery and timestamp for efficient querying
        TTL toDateTime(event_time) + toIntervalDay(30) -- Retain data for 30 days
        SETTINGS index_granularity = 8192, ttl_only_drop_parts = 1;