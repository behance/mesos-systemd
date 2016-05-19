#!/bin/bash -x

# NOTE: this script will need to be sudo'ed for access to /var/lib/docker

echo "Removing dead containers & volumes"
docker rm -v $(docker ps -a|grep Exited|cut -d" " -f1)  2> /dev/null

# top-level orphaned images have <none> in name.  rmi these
# rmi them one at a time so it's clear what is being done in the logs
docker images | grep none | awk '{print $3}' | xargs -n 1 -IXX docker rmi XX

# play on https://github.com/docker/docker/issues/6354#issuecomment-114688663
FSDRIVER=$(docker info|grep Storage|cut -d: -f2|tr -d [:space:])
echo "Driver $FSDRIVER"
echo "---- Complete ----"

sudo free -h
sudo lvdisplay

