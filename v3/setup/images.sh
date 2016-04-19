#!/bin/bash

if [ "$(etcdctl get images-base-bootstrapped)" == "true" ]; then
    echo "base images already bootstrapped, skipping"
    exit 0
fi
etcdctl set images-base-bootstrapped true
etcdctl mkdir splunk
etcdctl set /splunk/SPLUNK_FORWARD_SERVER "ds.adobesecaas.com:8089"
etcdctl set /images/splunkforwarder "adobeplatform/docker-splunk:latest"

# pull down images serially to avoid a FS layer clobbering bug in docker 1.6.x
docker pull behance/docker-gocron-logrotate
docker pull behance/docker-sumologic:latest
docker pull behance/docker-sumologic:syslog-latest
docker pull behance/docker-dd-agent
