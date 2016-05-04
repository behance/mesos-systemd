#!/bin/bash

source /etc/environment

if [ "${NODE_ROLE}" != "control" ]; then
    exit 0
fi

etcdctl set /zookeeper/config/exhibitor/s3-prefix "zk"
etcdctl set /zookeeper/config/exhibitor/s3-bucket $EXHIBITOR_S3BUCKET
etcdctl set /zookeeper/config/ensemble-size $CONTROL_CLUSTER_SIZE
etcdctl set /zookeeper/config/endpoint $ZOOKEEPER_ENDPOINT
etcdctl set /zookeeper/config/username "zk"
# default val - should be overwritten by etcd overrides (see init script)
etcdctl set /zookeeper/config/password "password"

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
sudo cp $SCRIPTDIR/../util-units/zk-health.service /etc/systemd/system/zk-health.service
sudo systemctl daemon-reload
