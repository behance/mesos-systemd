#!/bin/bash -x

if [ "$NODE_ROLE" != "proxy" ]; then
    exit 0
fi

PROXY_SETUP_IMAGE=behance/mesos-proxy-setup:latest

docker run \
    --name mesos-proxy-setup \
    --net='host' \
    --privileged \
    ${PROXY_SETUP_IMAGE}
