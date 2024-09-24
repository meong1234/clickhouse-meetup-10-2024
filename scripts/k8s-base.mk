# K8s support

KIND              := kindest/node:v1.26.3
TELEPRESENCE      := docker.io/datawire/tel2:2.17.0

k8s-docker-pull:
	docker pull $(KIND)
	docker pull $(TELEPRESENCE)

KIND_CLUSTER := clickhouse-starter-cluster

k8s-create-cluster:
	kind create cluster \
    		--image kindest/node:v1.26.3@sha256:61b92f38dff6ccc29969e7aa154d34e38b89443af1a2c14e6cfbd2df6419c66f \
    		--name $(KIND_CLUSTER) \

	kubectl wait --timeout=120s --namespace=local-path-storage --for=condition=Available deployment/local-path-provisioner

	kind load docker-image $(TELEPRESENCE) --name $(KIND_CLUSTER)
	telepresence --context=kind-$(KIND_CLUSTER) helm install
	telepresence --context=kind-$(KIND_CLUSTER) connect

k8s-delete-cluster:
	telepresence quit -s
	kind delete cluster --name $(KIND_CLUSTER)


ALTINITY-CLICKHOUSE-OPERATOR     := altinity/clickhouse-operator:0.23.3
ALTINITY-METRICS-EXPORTER        := altinity/metrics-exporter:0.23.3
CLICKHOUSE-SERVER        		 := clickhouse/clickhouse-server:24.2
GOOSE-MIGRATION        		 := ghcr.io/kukymbr/goose-docker:3.19.2

k8s-pull-apps-docker:
	docker pull $(ALTINITY-CLICKHOUSE-OPERATOR)
	docker pull $(ALTINITY-METRICS-EXPORTER)
	docker pull $(CLICKHOUSE-SERVER)
	docker pull $(GOOSE-MIGRATION)

	kind load docker-image $(ALTINITY-CLICKHOUSE-OPERATOR) --name $(KIND_CLUSTER)
	kind load docker-image $(ALTINITY-METRICS-EXPORTER) --name $(KIND_CLUSTER)
	kind load docker-image $(CLICKHOUSE-SERVER) --name $(KIND_CLUSTER)
	kind load docker-image $(GOOSE-MIGRATION) --name $(KIND_CLUSTER)