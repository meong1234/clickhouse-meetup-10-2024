import json
import random
import time
import argparse
import logging
from kafka import KafkaProducer
from kafka.errors import KafkaError
from datetime import datetime

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Function to generate random float values for voltage, current, etc.
def generate_random_data():
    return {
        "event_time": datetime.utcnow().isoformat(sep='T', timespec='milliseconds') + 'Z',
        "battery_serial": f"battery-{random.randint(1, 10):02d}",
        "latitude": round(random.uniform(-90.0, 90.0), 6),
        "longitude": round(random.uniform(-180.0, 180.0), 6),
        "state_of_charge": round(random.uniform(0.0, 100.0), 2),
        "state_of_health": round(random.uniform(60.0, 100.0), 2),
        "charge_cycles": random.randint(0, 1000),
        "battery_voltage": round(random.uniform(3000.0, 4500.0), 2),
        "battery_current": round(random.uniform(-200.0, 200.0), 2),
        "cell_voltages": [round(random.uniform(3.0, 4.2), 3) for _ in range(4)],
        "bms_temperature": round(random.uniform(20.0, 45.0), 2),
        "cell_temperatures": [round(random.uniform(20.0, 45.0), 2) for _ in range(4)]
    }

# Kafka producer configuration
def create_producer(bootstrap_servers):
    producer = KafkaProducer(
        bootstrap_servers=bootstrap_servers,
        api_version=(3, 7, 0),
        value_serializer=lambda v: json.dumps(v).encode('utf-8')  # JSON serialization
    )
    return producer

# Send data to Kafka with error handling
def send_to_kafka(producer, topic, partition_key, data):
    try:
        key_bytes = partition_key.encode('utf-8')
        future = producer.send(topic, key=key_bytes, value=data)
        future.get(timeout=10)  # Block until the message is sent (or timeout/error occurs)
        logging.info(f"Successfully sent data: {data}")
    except KafkaError as e:
        logging.error(f"Failed to send data: {data} due to error: {e}")

# Main function to repeatedly generate and send data
def main(bootstrap_servers, topic, interval):
    producer = create_producer(bootstrap_servers)

    try:
        while True:
            data = generate_random_data()
            battery_serial = data['battery_serial']  # Use battery_serial as partition key
            send_to_kafka(producer, topic, battery_serial, data)
            time.sleep(interval)  # Wait for the specified interval
    except KeyboardInterrupt:
        logging.info("Process interrupted by user. Exiting...")
    finally:
        producer.close()

# Command-line interface
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Send IoT battery metrics to Kafka.")
    parser.add_argument('--bootstrap-servers', type=str, default="kafka-hub-kafka-bootstrap.kafka-hub.svc.cluster.local:9092",
                        help="Kafka bootstrap servers")
    parser.add_argument('--topic', type=str, default="iot-battery",
                        help="Kafka topic name")
    parser.add_argument('--interval', type=float, default=1.0,
                        help="Time interval between messages (default: 1 second)")

    args = parser.parse_args()

    # Call the main function with arguments
    main(args.bootstrap_servers, args.topic, args.interval)
