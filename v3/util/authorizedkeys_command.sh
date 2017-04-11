#!/bin/bash

ROLE_NAME="$(etcdctl get /klam-ssh/config/role-name)"
ENCRYPTION_ID="$(etcdctl get /klam-ssh/config/encryption-id)"
ENCRYPTION_KEY="$(etcdctl get /klam-ssh/config/encryption-key)"
KEY_LOCATION_PREFIX="$(etcdctl get /klam-ssh/config/key-location-prefix)"
IMAGE="$(etcdctl get /images/klam-ssh)"

echo "Running authorizedkeys_command for $1" | systemd-cat -p info -t klam-ssh

docker run --rm -e ROLE_NAME=${ROLE_NAME} -e ENCRYPTION_ID=${ENCRYPTION_ID} -e ENCRYPTION_KEY=${ENCRYPTION_KEY} -e KEY_LOCATION_PREFIX=${KEY_LOCATION_PREFIX} ${IMAGE} /usr/lib/klam/getKeys.py $1
exit 0
