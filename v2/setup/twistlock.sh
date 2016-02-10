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

twistlockusername=$(etcdctl get /twistlockusername)
twistlockpassword=$(etcdctl get /twistlockpassword)
twistlockparameter=$(etcdctl get /twistlockparameter)

curl -sSL -k --header "authorization:Bearer \
$(eval echo $(echo $(curl -s -H "Content-Type: application/json" \
-d '{"username":"'$(eval echo $twistlockusername)'", "password":"'$(eval echo $twistlockpassword)'"}' \
https://"$(eval echo $twistlockparameter)":443/api/v1/authenticate) | sed -ne 's/.*"token":"\([^,]*\)".*/\1/p'))" \
https://"$(eval echo $twistlockparameter)"/api/v1/scripts/defender.sh \
-o defender.sh && chmod a+x defender.sh && sudo ./defender.sh
