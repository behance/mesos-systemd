#!/bin/bash -x

if [ "$NODE_ROLE" != "proxy" ]; then
    exit 0
fi

PROXY_SETUP_IMAGE=behance/mesos-proxy-setup:latest

docker run \
    --name mesos-proxy-setup \
    --log-opt max-size=10m --log-opt max-file=10  \
    --net='host' \
    --privileged \
    ${PROXY_SETUP_IMAGE}
