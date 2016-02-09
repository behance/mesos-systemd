#!/bin/bash

source /etc/environment

HOMEDIR=$(eval echo "~`whoami`")

sudo docker run --rm \
   -v ${HOMEDIR}:/data/ behance/docker-aws-s3-downloader \
    us-east-1 $CONTROL_TIER_S3SECURE_BUCKET .twistlock

while read line; do
  etcdctl set $line
done < ${HOMEDIR}/.twistlock

sudo docker run --rm \
   -v ${HOMEDIR}:/data/ behance/docker-aws-s3-downloader \
    us-east-1 $CONTROL_TIER_S3SECURE_BUCKET .twistlockparameter


while read line; do
  etcdctl set $line
done < ${HOMEDIR}/.twistlockparameter





