#!/bin/bash

if [[ -f /etc/profile.d/etcdctl.sh ]]; then
    source /etc/profile.d/etcdctl.sh
fi

etcdctl exec-watch /flight-director/users -- /usr/bin/bash -c \
'for user in $ETCD_WATCH_VALUE; \
do sudo useradd -p "*" -U -m $user -G docker; \
done'
