CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    customer_id INT NOT NULL,
    customer_name VARCHAR(255) NOT NULL,
    order_number VARCHAR(50) NOT NULL,
    order_state VARCHAR(20) NOT NULL,
    total_price DECIMAL(12, 2) NOT NULL
);

CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_order_number ON orders(order_number);
ALTER TABLE orders REPLICA IDENTITY FULL;