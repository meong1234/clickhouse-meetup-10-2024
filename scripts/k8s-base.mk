# K8s support

KIND              := kindest/node:v1.26.3

k8s-docker-pull:
	docker pull $(KIND)

KIND_CLUSTER := clickhouse-starter-cluster

k8s-create-cluster:
	kind create cluster \
    		--image kindest/node:v1.26.3@sha256:61b92f38dff6ccc29969e7aa154d34e38b89443af1a2c14e6cfbd2df6419c66f \
    		--name $(KIND_CLUSTER) \

	kubectl wait --timeout=120s --namespace=local-path-storage --for=condition=Available deployment/local-path-provisioner

k8s-delete-cluster:
	kind delete cluster --name $(KIND_CLUSTER)

ALTINITY-CLICKHOUSE-OPERATOR     := altinity/clickhouse-operator:0.23.3
ALTINITY-METRICS-EXPORTER        := altinity/metrics-exporter:0.23.3
CLICKHOUSE-SERVER        		 := clickhouse/clickhouse-server:24.2
GOOSE-MIGRATION        		 	 := ghcr.io/kukymbr/goose-docker:3.19.2
STRIMZI-OPERATOR        		 := quay.io/strimzi/operator:0.40.0
STRIMZI-KAFKA        		 	 := quay.io/strimzi/kafka:0.40.0-kafka-3.7.0
STRIMZI-KAFKA-CONNECT 			 := strimzi-kafka-connect:0.40.0-kafka-3.7.0

k8s-pull-apps-docker:
	docker pull $(ALTINITY-CLICKHOUSE-OPERATOR)
	docker pull $(ALTINITY-METRICS-EXPORTER)
	docker pull $(CLICKHOUSE-SERVER)
	docker pull $(GOOSE-MIGRATION)
	docker pull $(STRIMZI-OPERATOR)
	docker pull $(STRIMZI-KAFKA)
	docker build --progress=plain \
     		-f ./docker-images/strimzi-kafka-connect.Dockerfile \
     		--tag $(STRIMZI-KAFKA-CONNECT) \
     		.

	kind load docker-image $(ALTINITY-CLICKHOUSE-OPERATOR) --name $(KIND_CLUSTER)
	kind load docker-image $(ALTINITY-METRICS-EXPORTER) --name $(KIND_CLUSTER)
	kind load docker-image $(CLICKHOUSE-SERVER) --name $(KIND_CLUSTER)
	kind load docker-image $(GOOSE-MIGRATION) --name $(KIND_CLUSTER)
	kind load docker-image $(STRIMZI-OPERATOR) --name $(KIND_CLUSTER)
	kind load docker-image $(STRIMZI-KAFKA) --name $(KIND_CLUSTER)
	kind load docker-image $(STRIMZI-KAFKA-CONNECT) --name $(KIND_CLUSTER)
