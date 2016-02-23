#!/bin/bash

source /etc/environment

HOMEDIR=$(eval echo "~`whoami`")

sudo docker run --rm \
    -v ${HOMEDIR}:/data/ behance/docker-aws-s3-downloader \
     us-east-1 $CONTROL_TIER_S3SECURE_BUCKET ."$(echo $USER)"


while read line; do
  etcdctl set $line
done < ${HOMEDIR}/."$(echo $USER)"


twistlockclientusername=$(etcdctl get /twistlockclientusername)
twistlockclientpassword=$(etcdctl get /twistlockclientpassword)
twistlockparameter=$(etcdctl get /twistlockparameter)

#steps to generate private cert for each ssh user in HOMEDIR/.docker

curl -sSL -k --header "authorization:Bearer \
$(eval echo $(echo $(curl -s -H "Content-Type: application/json" \
-d '{"username":"'$(eval echo $twistlockclientusername)'", "password":"'$(eval echo $twistlockclientpassword)'"}' \
https://"$(eval echo $twistlockparameter)":443/api/v1/authenticate) | sed -ne 's/.*"token":"\([^,]*\)".*/\1/p'))" \
https://"$(eval echo $twistlockparameter)"/api/v1/cert/client-certs.sh | sh

#steps to run twistlock as proxy server

etcdctl set DOCKER_HOST tcp://$(eval echo $COREOS_PRIVATE_IPV4):9998
etcdctl set DOCKER_TLS_VERIFY 1


DOCKER_HOST=$(etcdctl get DOCKER_HOST)
export DOCKER_HOST

DOCKER_TLS_VERIFY=$(etcdctl get DOCKER_TLS_VERIFY)
export DOCKER_TLS_VERIFY
