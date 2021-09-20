FROM confluentinc/cp-server-connect-base:6.2.0

ENV CONNECT_PLUGIN_PATH="/usr/share/java,/usr/share/confluent-hub-components"

USER root
COPY --chown=appuser:appuser include/etc/confluent/docker /etc/confluent/docker
USER appuser

ARG CONNECTOR_OWNER=confluentinc
ARG CONNECTOR_NAME
ARG CONNECTOR_VERSION
RUN confluent-hub install --no-prompt confluent-hub install confluentinc/kafka-connect-syslog:1.3.4

CMD ["/etc/confluent/docker/run"]
