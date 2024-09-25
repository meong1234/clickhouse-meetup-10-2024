-- +goose Up
CREATE MATERIALIZED VIEW trx_agg_monthly_orders_mv
    TO trx_agg_monthly_orders
AS
SELECT formatDateTime(completed_at, '%Y-%m') AS year_month,
       customer_id,
       order_type,
       countState()                          AS total_orders,
       sumState(total_price)                 AS total_revenue
FROM trx_orders
WHERE order_state = 'completed' -- Aggregating only completed orders
GROUP BY customer_id, order_type, year_month;