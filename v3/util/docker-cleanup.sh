#!/bin/bash -x

# NOTE: this script will need to be sudo'ed for access to /var/lib/docker

echo "Removing dead containers & volumes"
docker rm -v $(docker ps -a|grep Exited|cut -d" " -f1) 2> /dev/null

echo "Removing images"
docker rmi $(docker images -aq) 2> /dev/null

# play on https://github.com/docker/docker/issues/6354#issuecomment-114688663
FSDRIVER=$(docker info|grep Storage|cut -d: -f2|tr -d [:space:])
FSLOC=/var/lib/docker/${FSDRIVER}
cd $FSLOC
echo "Starting image cleaning for driver:$FSDRIVER in $FSLOC"
for image in $(ls|grep -v -- '-init'|cut -f2); do
    docker inspect $image > /dev/null
    if [ $? == 0 ]; then
        echo "--> skipping $image"
        continue
    fi
    echo "--> removing $image"
    rm -r $image;
done

echo "---- Complete ----"
sudo free -h
sudo df -Th
