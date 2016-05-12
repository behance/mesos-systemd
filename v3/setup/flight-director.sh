#!/bin/bash -x

source /etc/environment

if [ "${NODE_ROLE}" != "control" ]  && [ "${NODE_ROLE}" != "it-hybrid" ]; then
    exit 0
fi
if [ "$(etcdctl get /bootstrap.service/flight-director)" == "true" ]; then
    exit 0
fi

etcdctl set /bootstrap.service/flight-director true
etcdctl setdir flight-director
etcdctl set /flight-director/config/api-server-port 2001
etcdctl set /flight-director/config/chronos-master "$FLIGHT_DIRECTOR_CHRONOS_ENDPOINT"
etcdctl set /flight-director/config/db-name "$FLIGHT_DIRECTOR_DB_NAME"
etcdctl set /flight-director/config/db-engine mysql
etcdctl set /flight-director/config/db-path "$FLIGHT_DIRECTOR_DB_PATH"
etcdctl set /flight-director/config/db-username "$FLIGHT_DIRECTOR_DB_USERNAME"
etcdctl set /flight-director/config/dockercfg-location file:///root/.dockercfg
etcdctl set /flight-director/config/debug false
etcdctl set /flight-director/config/event-interface ''
etcdctl set /flight-director/config/event-port 2001
etcdctl set /flight-director/config/fixtures "$FLIGHT_DIRECTOR_FIXTURES"
etcdctl set /flight-director/config/kv-server http://localhost:2379
etcdctl set /flight-director/config/log-level "$FLIGHT_DIRECTOR_LOG_LEVEL"
etcdctl set /flight-director/config/log-location "$FLIGHT_DIRECTOR_LOG_LOCATION"
etcdctl set /flight-director/config/log-marathon-api-calls false
etcdctl set /flight-director/config/marathon-master "$FLIGHT_DIRECTOR_MARATHON_ENDPOINT"
etcdctl set /flight-director/config/mesos-master "$FLIGHT_DIRECTOR_MESOS_ENDPOINT"
etcdctl set /flight-director/config/marathon-master-protocol http
etcdctl set /flight-director/config/allow-marathon-unverified-tls false
etcdctl set /flight-director/config/mesos-master-protocol http
etcdctl set /flight-director/config/authorizer-type airlock
