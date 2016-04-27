#!/bin/bash

source /etc/environment

if [ "${NODE_ROLE}" != "control" ]; then
    exit 0
fi

etcdctl set /zookeeper/s3_exhibitor_prefix "zk"
etcdctl set /zookeeper/s3_exhibitor_bucket $EXHIBITOR_S3BUCKET
etcdctl set /zookeeper/ensemble_size $CONTROL_CLUSTER_SIZE
etcdctl set /zookeeper/ZK_USERNAME "zk"

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
sudo cp $SCRIPTDIR/../util-units/zk-health.service /etc/systemd/system/zk-health.service
sudo systemctl daemon-reload
