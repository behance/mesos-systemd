#!/bin/bash

if [ "$(etcdctl get /bootstrap.service/images-base-bootstrapped)" == "true" ]; then
    echo "base images already bootstrapped, skipping"
    exit 0
fi
etcdctl set /bootstrap.service/images-base-bootstrapped true

# pull down images serially to avoid a FS layer clobbering bug in docker 1.6.x
docker pull behance/docker-gocron-logrotate
docker pull behance/docker-sumologic:latest
docker pull behance/docker-sumologic:syslog-latest
docker pull behance/docker-dd-agent
