-- +goose Up
CREATE TABLE IF NOT EXISTS trx_agg_monthly_orders
(
    year_month    String,
    customer_id   UInt64,
    order_type    LowCardinality(String),
    total_orders  AggregateFunction(count),
    total_revenue AggregateFunction(sum, Int64)
)
    ENGINE = AggregatingMergeTree()
        PARTITION BY year_month
        ORDER BY (customer_id, year_month, order_type);