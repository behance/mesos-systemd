#!/bin/bash -x

source /etc/environment

CONF_DIR=/run/systemd/system/fleet.service.d
if [ ! -d $CONF_DIR ]; then
    sudo mkdir $CONF_DIR
fi

# https://gist.github.com/skippy/d539442ada90be06459c
# TODO: discuss anything else that would be useful here
if [[ -z $ZONE ]]; then
	AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
fi
REGION=${AZ::-1}

METADATA="FLEET_METADATA=region=${REGION},az=${AZ},role=${NODE_ROLE},ip=${COREOS_PRIVATE_IPV4}"
echo -e "[Service]\nEnvironment='${METADATA}'" > $CONF_DIR/21-aws.conf

sudo systemctl daemon-reload
sudo systemctl restart fleet
