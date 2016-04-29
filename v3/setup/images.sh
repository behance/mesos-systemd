#!/bin/bash

if [ "$(etcdctl get images-base-bootstrapped)" == "true" ]; then
    echo "base images already bootstrapped, skipping"
    exit 0
fi
etcdctl set images-base-bootstrapped true

# pull down images serially to avoid a FS layer clobbering bug in docker 1.6.x
docker pull behance/docker-gocron-logrotate
docker pull behance/docker-sumologic:latest
docker pull behance/docker-sumologic:syslog-latest
docker pull behance/docker-dd-agent

# Adding klam-ssh image, which needs to be pulled globally
etcdctl set /images/klam-ssh   "adobecloudops/klam-ssh:latest"
docker pull adobecloudops/klam-ssh:latest
