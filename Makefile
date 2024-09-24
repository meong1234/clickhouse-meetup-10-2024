include scripts/*

setup-tools: brew-common

k8s-up: k8s-docker-pull k8s-create-cluster