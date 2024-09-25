-- +goose Up
CREATE TABLE IF NOT EXISTS trx_orders
(
    id            UInt64,
    created_at    DateTime64(3, 'UTC'),
    completed_at  DateTime64(3, 'UTC'),
    customer_id   UInt64,
    customer_name LowCardinality(String),
    order_number  String,
    order_state   LowCardinality(String),
    order_type    LowCardinality(String),
    total_price   Int64,
    INDEX idx_order_number order_number TYPE bloom_filter(0.01) GRANULARITY 1
)
    ENGINE = ReplacingMergeTree(completed_at)
        PARTITION BY toYYYYMM(completed_at)
        ORDER BY (customer_id, completed_at, order_number, order_type)
        SETTINGS index_granularity = 8192;