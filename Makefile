include scripts/*

setup-tools: brew-common python-common

k8s-up: k8s-docker-pull k8s-create-cluster k8s-pull-apps-docker

k8s-run: k8s-fluxcd-init k8s-init-telepresence

k8s-down: k8s-delete-telepresence k8s-delete-cluster

run-battery:
	python cli/battery-send-kafka.py --bootstrap-servers kafka-hub-kafka-bootstrap.kafka-hub.svc.cluster.local:9092 \
    		--topic iot-battery \
    		--interval 0.1