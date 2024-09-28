# DEMO Postgres -> Debezium -> Clickhouse

This demo shows how data flows from PostgreSQL orders to ClickHouse, showcasing real-time syncing, ETL processing, and querying aggregated data.

### Step 1: Insert Data into PostgreSQL
After the system is set up, we can begin inserting data into the orders table in PostgreSQL using the `run-orders.py` script.

```shell
make run-orders
```
* What it does: insert random data to order table
* Expected Result: `etl-orders-worker` processes new orders and inserts them into the trx_orders table in ClickHouse.
```json
{"@service":"etl-orders-worker","ddl_query":"INSERT INTO trx_orders (    id, created_at, completed_at, customer_id, customer_name,    order_number, order_state, order_type, total_price ) SETTINGS async_insert=1, wait_for_async_insert=1, wait_for_async_insert_timeout=120 VALUES (    ?, ?, ?, ?, ?,   ?, ?, ?, ?  );  ","label":"","level":"debug","msg":"handle DDL","path":"root.output.processors.2","query_parameter":[109,"2024-09-27 21:33:36.098196000","2024-09-28 01:33:36.098196000",6021,"Customer_388","ORD-7952","completed","TOPUP",57094],"time":"2024-09-28T04:33:36Z"}
```


### Step 2: Querying ClickHouse for Raw Data
After the ETL worker has inserted the orders into ClickHouse, you can query the trx_orders table for raw data.

* Action: Run queries on the trx_orders table to verify that the data has been correctly inserted.
* Expected Result: You will see the raw order data in ClickHouse.

```sql
SELECT * FROM trx_orders ORDER BY completed_at DESC LIMIT 5;
```


### Step 3: Aggregated Data with Materialized Views
To improve query performance and provide pre-aggregated data for reporting, a materialized view is created on top of the trx_orders table. This view automatically aggregates orders by month and customer.

Materialized View Definition:
```sql
CREATE MATERIALIZED VIEW trx_agg_monthly_orders_mv
    TO trx_agg_monthly_orders
AS
SELECT formatDateTime(completed_at, '%Y-%m') AS year_month,
       customer_id,
       order_type,
       countState() AS total_orders,
       sumState(total_price) AS total_revenue
FROM trx_orders
WHERE order_state = 'completed'
GROUP BY customer_id, order_type, year_month;
```

* Action: Run queries on the trx_agg_monthly_orders table to retrieve monthly aggregated data.
* Expected Result: Aggregated data such as total orders and total revenue by customer and month.

```sql
SELECT customer_id, year_month, COUNTMerge(total_orders) AS total_orders, SUMMerge(total_revenue) AS total_revenue
FROM trx_agg_monthly_orders
GROUP BY customer_id, year_month;
```

#### Additional Thoughts
* Auto-updates: The trx_agg_monthly_orders table will be auto-updated with every new order inserted into the system.
* Performance: Materialized views provide optimized, pre-aggregated data for reporting, which can be crucial for analytics in production environments.