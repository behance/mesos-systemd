#!/bin/bash

source /etc/environment

# doing this for the time being because we're relying ENV vars in /etc/environment
if [ "${NODE_ROLE}" != "control" ]  && [ "${NODE_ROLE}" != "it-hybrid" ]; then
    exit 0
fi

if [ "$(etcdctl get /bootstrap.service/capcom)" == "true" ]; then
    exit 0
fi
etcdctl set /bootstrap.service/capcom              true

etcdctl setdir capcom
etcdctl set /capcom/config/applications            '[]'
etcdctl set /capcom/config/host                    127.0.0.1
etcdctl set /capcom/config/db-path                 ./capcom.db
etcdctl set /capcom/config/kv-store-server-address http://$CAPCOM_KV_ENDPOINT
etcdctl set /capcom/config/kv-ttl                  10
etcdctl set /capcom/config/log-level               "$CAPCOM_LOG_LEVEL"
etcdctl set /capcom/config/log-location            "$CAPCOM_LOG_LOCATION"
etcdctl set /capcom/config/port                    2002
etcdctl set /capcom/config/proxy                   nginx
etcdctl set /capcom/config/proxy-config-file       /etc/nginx/nginx.conf
etcdctl set /capcom/config/proxy-enabled           true
etcdctl set /capcom/config/proxy-restart-script    /restart_nginx_docker.sh
etcdctl set /capcom/config/proxy-timeout           60000
etcdctl set /capcom/config/proxy-docker-command    "nginx -g 'daemon off;'"
etcdctl set /capcom/config/ssl-cert-location       ""
