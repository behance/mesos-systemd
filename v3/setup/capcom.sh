#!/bin/bash

source /etc/environment

# doing this for the time being because we're relying ENV vars in /etc/environment
if [ "${NODE_ROLE}" != "control" ]  && [ "${NODE_ROLE}" != "it-hybrid" ]; then
    exit 0
fi

if [ "$(etcdctl get capcom-bootstrapped)" == "true" ]; then
    exit 0
fi


etcdctl set capcom-bootstrapped true

etcdctl setdir CP
etcdctl set /CP/CP_APPLICATIONS '[]'
etcdctl set /CP/CP_HOST 127.0.0.1
etcdctl set /CP/CP_DB_PATH ./capcom.db
etcdctl set /CP/CP_KV_STORE_SERVER_ADDRESS  http://$CAPCOM_KV_ENDPOINT
etcdctl set /CP/CP_KV_TTL 10
etcdctl set /CP/CP_LOG_LEVEL "$CAPCOM_LOG_LEVEL"
etcdctl set /CP/CP_LOG_LOCATION "$CAPCOM_LOG_LOCATION"
etcdctl set /CP/CP_PORT 2002
etcdctl set /CP/CP_PROXY nginx
etcdctl set /CP/CP_PROXY_CONFIG_FILE /etc/nginx/nginx.conf
etcdctl set /CP/CP_PROXY_ENABLED true
etcdctl set /CP/CP_PROXY_RESTART_SCRIPT /restart_nginx_docker.sh
etcdctl set /CP/CP_PROXY_TIMEOUT 60000
etcdctl set /CP/CP_PROXY_DOCKER_COMMAND "nginx -g 'daemon off;'"
etcdctl set /CP/CP_SSL_CERT_LOCATION ""