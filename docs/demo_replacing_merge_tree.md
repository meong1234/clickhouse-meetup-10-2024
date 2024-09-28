# Demonstration of ReplacingMergeTree with IoT Battery Data
This demonstration We'll illustrate how the ReplacingMergeTree and Materialized Views work together to maintain an up-to-date view of battery locations without needing to scan through huge volumes of time-series data.


## Step 1: Ingest Battery Data into Kafka
Start by running the `run-battery.py` script to simulate IoT battery data being published to Kafka. This data represents telemetry from multiple batteries, including location, battery health, and temperature.

```shell
make run-battery
```
* `What it does`: The script simulates random battery data and sends it to Kafka.
* `Expected Result`: The ETL battery workers will consume the Kafka data and insert it into the `iot_battery_metrics` table in ClickHouse.

## Step 2: IoT Battery Metrics Table
The battery data is inserted into the `iot_battery_metrics` table, which stores detailed telemetry for each battery.

```sql
CREATE TABLE IF NOT EXISTS iot_battery_metrics
(
    event_time         DateTime64(9) CODEC (Delta(8), ZSTD(1)),
    battery_serial     LowCardinality(String),
    latitude           Float64 CODEC (ZSTD(1)),
    longitude          Float64 CODEC (ZSTD(1)),
    state_of_charge    Float64 CODEC (ZSTD(1)),
    state_of_health    Float64 CODEC (ZSTD(1)),
    charge_cycles      UInt32 CODEC (ZSTD(1)),
    battery_voltage    Float64 CODEC (ZSTD(1)),
    battery_current    Float64 CODEC (ZSTD(1)),
    battery_power      Float64 MATERIALIZED abs((battery_voltage / 1000) * (battery_current / 1000)),
    cell_voltages      Array(Float64) CODEC (ZSTD(1)),
    min_cell_voltage   Float64 MATERIALIZED arrayMin(cell_voltages),
    max_cell_voltage   Float64 MATERIALIZED arrayMax(cell_voltages),
    voltage_difference Float64 MATERIALIZED (max_cell_voltage - min_cell_voltage),
    bms_temperature    Float64 CODEC (ZSTD(1)),
    cell_temperatures  Array(Float64) CODEC (ZSTD(1)),
    min_cell_temperature Float64 MATERIALIZED arrayMin(cell_temperatures),
    max_cell_temperature Float64 MATERIALIZED arrayMax(cell_temperatures),
    INDEX idxevent_time event_time TYPE minmax GRANULARITY 1
)
ENGINE = MergeTree
PARTITION BY toDate(event_time)
ORDER BY (battery_serial, toUnixTimestamp64Nano(event_time))
TTL toDateTime(event_time) + toIntervalDay(30)
SETTINGS index_granularity = 8192, ttl_only_drop_parts = 1;
```

```sql
SELECT battery_serial, latitude, longitude, max(event_time) as last_event_time
FROM iot_battery_metrics
WHERE latitude IS NOT NULL
  AND longitude IS NOT NULL
GROUP BY battery_serial
ORDER BY battery_serial;
```

However, querying this table directly for the last known location of a battery is inefficient due to the large volume of data (e.g., 40 million records/day).

## Step 3: Creating a ReplacingMergeTree for Battery Locations
To solve this, we use a ReplacingMergeTree to store only the latest location of each battery. 

This ensures that only the most recent row for each battery is kept, based on the last_event_time.

```sql
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
```

* ReplacingMergeTree ensures that only the latest record for each battery is kept, reducing the need to query the full history of battery data.

## Step 4: Automatically Updating Battery Locations with a Materialized View
We use a Materialized View to ensure that the iot_battery_last_location table is always up to date with the latest valid location data.

Materialized View Definition:
```sql
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
```

* `How it works`: Every time new battery data is inserted into iot_battery_metrics, the Materialized View automatically updates the corresponding row in the iot_battery_last_location table with the latest location.

## Step 5: Querying the Last Known Location of Batteries
With the iot_battery_last_location table in place, you can now easily query the last known location of any battery.

```sql
SELECT battery_serial, last_valid_latitude, last_valid_longitude, last_event_time
FROM iot_battery_last_location
ORDER BY battery_serial;
```

* `Result`: This query retrieves the most recent valid location of each battery, optimized for performance since it only searches through a small table of the latest data for each battery.
