# FluxCD Automation Workflow
In this project, FluxCD handles the entire setup, from bootstrapping to deploying workers that consume data from Kafka and insert it into ClickHouse.

the configurations defined in the `clusters/local-cluster/kustomization.yaml`
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - bootstrap.yaml
  - operators.yaml
  - databases.yaml
  - kafka.yaml
  - workers.yaml
```

Here’s how each file plays a role in the setup:

* `bootstrap.yaml`: This file bootstraps the basic infrastructure, including Helm repositories and Custom Resource Definitions (CRDs). It sets the foundation for the entire project.


* `operators.yaml`: Deploys Kubernetes operators for managing stateful applications. Specifically, this installs the Altinity ClickHouse Operator, CloudNativePG Operator for PostgreSQL, and Strimzi Operator for Kafka.


* `databases.yaml`: Defines and deploys the actual databases, including ClickHouse and PostgreSQL. It also triggers the execution of migration jobs, using `Goose` for ClickHouse and `Flyway` for PostgreSQL.


* `kafka.yaml`: Deploys Kafka and Kafka Connect using the Strimzi Operator. It also configures Kafka topics and connectors, such as Debezium, to capture changes from the PostgreSQL orders table and stream them to Kafka topics.


* `workers.yaml`: Finally, this file deploys the ETL workers responsible for consuming data from Kafka topics. The workers process the data (e.g., IoT battery data or order transactions) and insert it into ClickHouse for further analysis.