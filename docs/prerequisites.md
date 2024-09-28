# Prerequisites
Before running this project, ensure you have the necessary tools and dependencies installed on your local machine. Follow the steps below to set up your environment.


## 1. Install Dependencies
Install all the required tools and dependencies (Kubernetes, FluxCD, Python packages, etc.) using this command:
```shell
make setup-tools
```
* What it does: Installs kubectl, kustomize, k9s, flux, and necessary Python libraries for interacting with Kafka and PostgreSQL.

## 2. Create Kubernetes Cluster
Create the local Kubernetes cluster using kind:
```shell
make k8s-create-cluster
```
* What it does: Creates a local Kubernetes cluster named clickhouse-starter-cluster using the kind image kindest/node:v1.26.3 and ensures that the local path storage provisioner is available.

## 3. Pull and Load Docker Images
Pull the required Docker images and load them into the Kubernetes cluster:
```shell
make k8s-docker-pull
make k8s-load-docker
```
* What it does: Pulls and loads necessary Docker images for ClickHouse, PostgreSQL, Kafka, Debezium, Flyway, and others into the local Kubernetes cluster to ensure everything is available for the deployments.

## 4. Preload FluxCD Components
Preload the FluxCD components into the Kubernetes cluster:
```shell
make k8s-preload-fluxcd
```
* What it does: Preloads FluxCD-related Docker images into the cluster, speeding up deployment by avoiding delays in downloading during runtime.

## 5. Run the Project
Bring up the full stack, including ClickHouse, PostgreSQL, Kafka, and ETL pipelines, using:
```shell
make k8s-run
```
* What it does: Deploys all necessary components (databases, operators, Kafka, etc.) into the Kubernetes cluster. This also sets up the required Helm charts and operators using FluxCD.

## 6. Clean Up the Cluster
Once you are done, you can clean up by removing the Telepresence setup and deleting the Kubernetes cluster:
```shell
make k8s-down
```
* What it does: Deletes the Telepresence environment and removes the Kubernetes cluster.


## Notes
FluxCD will sync to your GitHub repository, and you need to set up a GitHub token for authentication. Follow these steps:

1. Visit [GitHub Settings](https://github.com/settings/apps).
2. Under **"Personal access tokens (classic)"**, click on the **Generate new token** button.
3. Set **No Expiration** for the token, or choose a valid expiration period.
4. Assign the following **GitHub Token Permissions**:
    - **repo**: Full control of private repositories (for read and write access to repositories FluxCD will interact with).

Once generated, set the environment variables:

```sh
export GITHUB_TOKEN=<your-github-token>
export GITHUB_USER=<your-github-username>
```

For more details, refer to the official [FluxCD GitHub Token Setup Guide](https://fluxcd.io/flux/installation/bootstrap/github/).