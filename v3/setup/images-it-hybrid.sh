#!/bin/bash

source /etc/environment

if [ "${NODE_ROLE}" != "it-hybrid" ]; then
    exit 0
fi

if [ "$(etcdctl get images-it-hybrid-bootstrapped)" == "true" ]; then
    echo "it-hybrid-tier images already bootstrapped, skipping"
    exit 0
fi
etcdctl set images-it-hybrid-bootstrapped true

etcdctl set /images/fd           "behance/flight-director:latest"

etcdctl set /images/capcom       "behance/capcom:latest"


docker pull $(etcdctl get /images/fd)
docker pull $(etcdctl get /images/capcom)
