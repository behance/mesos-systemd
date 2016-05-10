#!/bin/bash

source /etc/environment

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "${NODE_ROLE}" != "worker" ]; then
    exit 0
fi

docker pull "behance/iam-docker:latest"

export NETWORK="bridge"
export GATEWAY="$(ifconfig docker0 | grep "inet " | awk -F: '{print $1}' | awk '{print $2}')"
export INTERFACE="docker0"

# These will not work until Docker > 1.9 is running
#export GATEWAY="$(docker network inspect "$NETWORK" | grep Gateway | cut -d '"' -f 4)"
#export INTERFACE="br-$(docker network inspect "$NETWORK" | grep Id | cut -d '"' -f 4 | head -c 12)"

sudo iptables -t nat -I PREROUTING -p tcp -d 169.254.169.254 --dport 80 -j DNAT --to-destination "$GATEWAY":8080 -i "$INTERFACE"

sudo fleetctl submit "${SCRIPTDIR}/../util-units/iam-proxy.service"
sudo fleetctl start "iam-proxy.service"

# sudo cp "${SCRIPTDIR}/../util-units/iam-proxy.service" /etc/systemd/system/
# sudo systemctl start iam-proxy.service

# Wait until service is active
until [ "`/usr/bin/docker inspect -f {{.State.Running}} iam-proxy`" == "true" ]; do
	echo "Waiting for iam-proxy service..."
    sleep 5;
done;

exit 0
