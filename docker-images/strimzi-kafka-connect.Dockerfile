ARG STRIMZI_VERSION=0.40.0-kafka-3.7.0
FROM quay.io/strimzi/kafka:${STRIMZI_VERSION}

USER root:root

ARG DEBEZIUM_CONNECTOR_VERSION=2.5.0.Final
ENV KAFKA_CONNECT_PLUGIN_PATH=/opt/kafka/plugins

## Deploy postgres connector
RUN mkdir -p $KAFKA_CONNECT_PLUGIN_PATH/postgres && cd $KAFKA_CONNECT_PLUGIN_PATH/postgres && \
    curl -fSL https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/${DEBEZIUM_CONNECTOR_VERSION}/debezium-connector-postgres-${DEBEZIUM_CONNECTOR_VERSION}-plugin.tar.gz \
    | tar -xz -C $KAFKA_CONNECT_PLUGIN_PATH/postgres


RUN ls -l $KAFKA_CONNECT_PLUGIN_PATH
RUN ls -l $KAFKA_CONNECT_PLUGIN_PATH/postgres

USER 1001