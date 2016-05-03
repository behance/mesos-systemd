#!/usr/bin/bash -xe

source /etc/environment
docker pull behance/docker-aws-secrets-downloader:latest

DL_TABLE="sudo docker run behance/docker-aws-secrets-downloader --table $SECRETS_TABLE"
# Get all available secrets and configs
AV_SECRETS=$($DL_TABLE --key secrets)
AV_CONFIGS=$($DL_TABLE --key configs)

echo "$AV_SECRETS" | while read line ; do
    SECRET=$($DL_TABLE --key secrets --name $line)
    SECRET_TYPE=`echo $SECRET | cut -d' ' -f2`
    SECRET_PATH=`echo $SECRET | cut -d' ' -f3`
    SECRET_VAL=`echo $SECRET | cut -d' ' -f4-`

    if [[ "$SECRET_TYPE" != "etcd" ]]; then
        continue
    fi

    etcdctl set -- $SECRET_PATH "$SECRET_VAL"
done

echo "$AV_CONFIGS" | while read line ; do
    CONFIG=$($DL_TABLE --key configs --name $line)
    CONFIG_PATH=`echo $CONFIG | cut -d' ' -f1`
    CONFIG_VAL=`echo $CONFIG | cut -d' ' -f2-`

    etcdctl set -- $CONFIG_PATH "$CONFIG_VAL"
done
