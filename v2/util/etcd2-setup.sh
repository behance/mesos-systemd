#!/bin/bash

# NOTE: this needs to be run with sudo privileges
# $1 must be the SCRIPTDIR

echo "-------Control node found, setting up etcd peers-------"

mkdir -p /etc/systemd/system/etcd2.service.d
DROPIN_FILE=/etc/systemd/system/etcd2.service.d/30-etcd_peers.conf

cat > $DROPIN_FILE <<EOF
[Service]
# Load the other hosts in the etcd leader autoscaling group from file
EnvironmentFile=/etc/sysconfig/etcd-peers
EOF

chown root:root $DROPIN_FILE
chmod 0644 $DROPIN_FILE

# Sometimes this is needed?
systemctl daemon-reload

SCRIPTDIR=$1
cp "${SCRIPTDIR}/v2/util-units/etcd-peers.service" /etc/systemd/system/
systemctl start etcd-peers

echo "-------Waiting for etcd2 to start-------"
until etcdctl cluster-health
do
  sleep 8
done

echo "-------etcd2 started, continuing with bootstrapping-------"
