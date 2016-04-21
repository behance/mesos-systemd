#!/bin/bash

source /etc/environment

if [ "${NODE_ROLE}" != "control" ]  && [ "${NODE_ROLE}" != "it-hybrid" ]; then
    exit 0
fi

if [ "$(etcdctl get fd-bootstrapped)" == "true" ]; then
    exit 0
fi
etcdctl set fd-bootstrapped true

etcdctl setdir FD
etcdctl set /FD/FD_API_SERVER_PORT 2001
etcdctl set /FD/FD_CHRONOS_MASTER "$FLIGHT_DIRECTOR_CHRONOS_ENDPOINT"
etcdctl set /FD/FD_DB_DATABASE "$FLIGHT_DIRECTOR_DB_NAME"
etcdctl set /FD/FD_DB_ENGINE mysql
etcdctl set /FD/FD_DB_PASSWORD "$FLIGHT_DIRECTOR_DB_PASSWORD"
etcdctl set /FD/FD_DB_PATH "$FLIGHT_DIRECTOR_DB_PATH"
etcdctl set /FD/FD_DB_USERNAME "$FLIGHT_DIRECTOR_DB_USERNAME"
etcdctl set /FD/FD_DOCKERCFG_LOCATION file:///root/.dockercfg
etcdctl set /FD/FD_DEBUG false
etcdctl set /FD/FD_EVENT_INTERFACE ''
etcdctl set /FD/FD_EVENT_PORT 2001
etcdctl set /FD/FD_FIXTURES "$FLIGHT_DIRECTOR_FIXTURES"
etcdctl set /FD/FD_KV_SERVER http://localhost:2379
etcdctl set /FD/FD_LOG_LEVEL "$FLIGHT_DIRECTOR_LOG_LEVEL"
etcdctl set /FD/FD_LOG_LOCATION "$FLIGHT_DIRECTOR_LOG_LOCATION"
etcdctl set /FD/FD_LOG_MARATHON_API_CALLS false
etcdctl set /FD/FD_MARATHON_MASTER "$FLIGHT_DIRECTOR_MARATHON_ENDPOINT"
etcdctl set /FD/FD_MESOS_MASTER "$FLIGHT_DIRECTOR_MESOS_ENDPOINT"
etcdctl set /FD/FD_MARATHON_MASTER_PROTOCOL http
etcdctl set /FD/FD_ALLOW_MARATHON_UNVERIFIED_TLS false
etcdctl set /FD/FD_MESOS_MASTER_PROTOCOL http

etcdctl set /FD/AUTHORIZER_TYPE airlock