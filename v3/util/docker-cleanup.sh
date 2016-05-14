#!/bin/bash

# NOTE: this script will need to be sudo'ed for access to /var/lib/docker

echo "Removing dead containers & volumes"
docker rm -v $(docker ps -a|grep Exited|cut -d" " -f1)  #2> /dev/null

docker images | grep none | awk '{print $3}' | xargs -n 1 -IXX docker rmi XX
#echo "Removing images"
#docker rmi $(docker images -aq) 2> /dev/null

# play on https://github.com/docker/docker/issues/6354#issuecomment-114688663
FSDRIVER=$(docker info|grep Storage|cut -d: -f2|tr -d [:space:])
echo "Driver $FSDRIVER"
echo "---- Complete ----"

sudo free -h
sudo lvdisplay

