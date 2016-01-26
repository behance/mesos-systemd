#!/bin/bash

source /etc/environment

HOMEDIR=$(eval echo "~`whoami`")

sudo docker run --rm \
   -v ${HOMEDIR}:/data/ behance/docker-aws-s3-downloader \
    us-east-1 $CONTROL_TIER_S3SECURE_BUCKET .twistlock


while read line; do
  etcdctl set $line
done < ${HOMEDIR}/.twistlock



twistlockusername=$(etcdctl get /twistlockusername)
twistlockpassword=$(etcdctl get /twistlockpassword)

curl -sSL -k --header "authorization:Bearer $(eval echo $(echo $(curl -s -H "Content-Type: application/json" -d '{"username":"'$(eval echo $twistlockusername)'", "password":"'$(eval echo $twistlockpassword)'"}' https://adobe.console.twistlock.com:443/api/v1/authenticate) | sed -ne 's/.*"token":"\([^,]*\)".*/\1/p'))" https://adobe.console.twistlock.com/api/v1/cert/client-certs.sh | sh


curl -sSL -k --header "authorization:Bearer $(eval echo $(echo $(curl -s -H "Content-Type: application/json" -d '{"username":"'$(eval echo $twistlockusername)'", "password":"'$(eval echo $twistlockpassword)'"}' https://adobe.console.twistlock.com:443/api/v1/authenticate) | sed -ne 's/.*"token":"\([^,]*\)".*/\1/p'))" https://adobe.console.twistlock.com/api/v1/scripts/defender.sh -o defender.sh && chmod a+x defender.sh && sudo ./defender.sh
