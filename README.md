Welcome to this demo project, developed for the ClickHouse Meetup in Jakarta. This hands-on guide demonstrates how to build a scalable, real-time data analytics platform using industry-standard tools like ClickHouse, PostgreSQL, Kafka, Debezium, Benthos, and Kubernetes.

# Overview

The project takes you through the full lifecycle of designing, deploying, and automating a modern data platform. You will learn how to synchronize transactional data from PostgreSQL to ClickHouse for high-performance analytics using a fully automated pipeline managed by FluxCD in a Kubernetes environment.

This repository serves as a comprehensive example, showcasing:
* Setting up a real-time ETL pipeline.
* Deploying, syncing, and scaling data between databases.
* Automating infrastructure with GitOps using FluxCD.

### Key Features
* `End-to-End Data Analytics`: Seamlessly integrates PostgreSQL (transactional database) with ClickHouse (analytics database) for handling real-time analytics workloads.
* `Real-Time Data Synchronization`: Utilizes Debezium and Kafka to stream changes from PostgreSQL to ClickHouse in real time.
* `ETL Pipeline`: Processes data streams using Benthos, enabling efficient data transformation and ingestion into ClickHouse.
* `GitOps & Automation`: Complete infrastructure and deployment automation using FluxCD, ensuring continuous delivery and syncing with your GitHub repository.

### Tech Stack
The demo utilizes the following technology stack:

* *Kubernetes* (kind) for local orchestration.
* *ClickHouse* for performing real-time analytics.
* *PostgreSQL* as the transactional database.
* *Kafka* for real-time data streaming.
* *Debezium* for change data capture from PostgreSQL.
* *Benthos* for ETL processing (Extract, Transform, Load).
* *FluxCD* for continuous deployment and GitOps automation.

### Project Structure
The project is organized into several key directories, each containing relevant components and configuration files:

* **bootstrap/**: Contains setup for Helm repositories and Custom Resource Definitions (CRDs).
* **cli/**: CLI tools for inserting and managing data (`battery-send-kafka.py` and `orders-insert-pg.py`).
* **clusters/**: Configuration for the Kubernetes cluster and its resources, mainly used by FluxCD.
* **database/**: Database definitions for ClickHouse and PostgreSQL, along with their migration scripts.
* **docs/**: Documentation files explaining various aspects of the project.
* **docker-images/**: Custom Dockerfiles, including one for Strimzi Kafka Connect.
* **etl-workers/**: Definitions for the ETL workers handling data transformations.
* **kafka/**: Configuration for Kafka clusters, Kafka Connect, and Debezium connectors.
* **operators/**: Kubernetes operators for ClickHouse, PostgreSQL, and Kafka.
* **scripts/**: Makefile scripts for setting up the environment and managing the Kubernetes cluster.

# Setup and Deployment
Before running the project, ensure you have installed the necessary tools. Detailed instructions are provided in the [Prerequisites Documentation](./docs/prerequisites.md).

```shell
make k8s-up
make k8s-run
```

More details on the deployment process can be found in the [CICD Workflow Documentation](./docs/fluxcd_workflow.md).

## Demo Scenarios
This repository includes two main demo scenarios:

### PostgreSQL to ClickHouse Syncing:
Demonstrates the real-time syncing of data from PostgreSQL to ClickHouse using Debezium and Kafka.  
For a step-by-step walkthrough, refer to the [PostgreSQL-Debezium-ClickHouse Demo](./docs/demo_postgres_debezium_clickhouse.md).

### IoT Battery Data with ReplacingMergeTree:
Illustrates how ReplacingMergeTree and Materialized Views can be used to efficiently manage and query IoT time-series data.  
Check out the detailed steps in the [ReplacingMergeTree Demo](./docs/demo_replacing_merge_tree.md).
