#!/bin/bash -x

ENV_FILE="/etc/environment"
ETCD_PREFIX="/environment"
IGNORED='^NODE|^COREOS|^#|^FLIGHT_DIRECTOR|^CAPCOM'

for line in $(cat $ENV_FILE|egrep -v $IGNORED); do
    key=${line%=*}
    value=${line#*=}

    etcdkey="$ETCD_PREFIX/$key"
    etcdctl set $etcdkey $value
done
