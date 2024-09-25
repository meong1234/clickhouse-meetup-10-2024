import random
import time
import argparse
import logging
from datetime import datetime, timedelta
import psycopg2
from psycopg2 import sql

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Function to generate random order data
def generate_random_order():
    order_type_options = ['SWAP', 'TOPUP', 'RENTAL', 'OPS']
    order_state_options = ['completed']

    # Generate order data
    created_at = datetime.utcnow()
    completed_at = created_at + timedelta(hours=random.randint(1, 24)) if random.choice(order_state_options) == 'completed' else None

    return {
        "customer_id": random.randint(1, 10000),
        "customer_name": f"Customer_{random.randint(1, 1000)}",
        "order_number": f"ORD-{random.randint(1000, 9999)}",
        "order_state": random.choice(order_state_options),
        "order_type": random.choice(order_type_options),
        "total_price": random.randint(1000, 100000),
        "created_at": created_at,
        "completed_at": completed_at
    }

# Function to connect to PostgreSQL database
def create_db_connection(dbname, user, password, host, port):
    conn = psycopg2.connect(
        dbname=dbname,
        user=user,
        password=password,
        host=host,
        port=port
    )
    return conn

# Function to insert order data into PostgreSQL
def insert_order_to_db(conn, order_data):
    try:
        with conn.cursor() as cursor:
            insert_query = sql.SQL("""
                INSERT INTO postgres.orders (created_at, completed_at, customer_id, customer_name, order_number, order_state, order_type, total_price)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """)
            cursor.execute(insert_query, (
                order_data['created_at'],
                order_data['completed_at'],
                order_data['customer_id'],
                order_data['customer_name'],
                order_data['order_number'],
                order_data['order_state'],
                order_data['order_type'],
                order_data['total_price']
            ))
            conn.commit()
            logging.info(f"Successfully inserted order: {order_data}")
    except Exception as e:
        logging.error(f"Failed to insert order: {order_data} due to error: {e}")
        conn.rollback()

# Main function to repeatedly generate and insert order data
def main(dbname, user, password, host, port, interval):
    conn = create_db_connection(dbname, user, password, host, port)

    try:
        while True:
            order_data = generate_random_order()
            insert_order_to_db(conn, order_data)
            time.sleep(interval)
    except KeyboardInterrupt:
        logging.info("Process interrupted by user. Exiting...")
    finally:
        conn.close()

# Command-line interface
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Insert random order data into PostgreSQL.")
    parser.add_argument('--dbname', type=str, default="orders_db", help="PostgreSQL database name")
    parser.add_argument('--user', type=str, default="user", help="PostgreSQL user")
    parser.add_argument('--password', type=str, default="password", help="PostgreSQL password")
    parser.add_argument('--host', type=str, default="localhost", help="PostgreSQL host")
    parser.add_argument('--port', type=int, default=5432, help="PostgreSQL port")
    parser.add_argument('--interval', type=float, default=1.0, help="Time interval between inserts (default: 1 second)")

    args = parser.parse_args()

    # Call the main function with arguments
    main(args.dbname, args.user, args.password, args.host, args.port, args.interval)
