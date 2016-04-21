#!/usr/bin/bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOMEDIR=$(eval echo "~`whoami`")
OWNER=$(whoami)

source /etc/environment

TABLE=`sudo echo $SECRETS_TABLE`
docker pull behance/docker-aws-secrets-downloader:latest

# Get all available secrets and configs
AV_SECRETS=`sudo docker run behance/docker-aws-secrets-downloader --table $TABLE --key secrets`
AV_CONFIGS=`sudo docker run behance/docker-aws-secrets-downloader --table $TABLE --key configs`

printf "#!/bin/bash\nsource /etc/environment\n" >  ${HOMEDIR}/.etcd_loader.sh

echo "$AV_SECRETS" | while read line ; do
    SECRET=`sudo docker run behance/docker-aws-secrets-downloader --table $TABLE --key secrets --name $line`
    SECRET_TYPE=`echo $SECRET | cut -d' ' -f2`
    SECRET_PATH=`echo $SECRET | cut -d' ' -f3`
    SECRET_VAL=`echo $SECRET | cut -d' ' -f4-`

    if [[ "$SECRET_TYPE" = "etcd" ]]; then
        echo "Setting ETCD value for secret: $SECRET_PATH"
        #etcdctl set $SECRET_PATH $SECRET_VAL &>/dev/null
        printf "etcdctl set -- %s \"%s\" &>/dev/null \n" "$SECRET_PATH" "$SECRET_VAL" >> ${HOMEDIR}/.etcd_loader.sh
    fi
done

echo "$AV_CONFIGS" | while read line ; do
    CONFIG=`docker run behance/docker-aws-secrets-downloader --table $TABLE --key configs --name $line`
    CONFIG_PATH=`echo $CONFIG | cut -d' ' -f1`
    CONFIG_VAL=`echo $CONFIG | cut -d' ' -f2-`

    echo "Setting ETCD value for config: $CONFIG_PATH"
    #etcdctl set $CONFIG_PATH $CONFIG_VAL &>/dev/null
    printf "etcdctl set %s \"%s\" &>/dev/null \n" "$CONFIG_PATH" "$CONFIG_VAL" >> ${HOMEDIR}/.etcd_loader.sh
done

chmod +x ${HOMEDIR}/.etcd_loader.sh
${HOMEDIR}/.etcd_loader.sh
rm ${HOMEDIR}/.etcd_loader.sh

# Create a dockercfg
DOCKERCFG_CONTENTS=`sudo docker run behance/docker-aws-secrets-downloader --table $TABLE --key secrets --name DOCKERCFG --format plain`
echo "$DOCKERCFG_CONTENTS" > /home/${OWNER}/.dockercfg
sudo chown -R ${OWNER}:${OWNER} /home/${OWNER}/.dockercfg
sudo cp /home/${OWNER}/.dockercfg /root/.dockercfg

# Save the Git Pull Key (must decode base64 since using "plain" option)
GIT_PULL_KEY_CONTENTS=`sudo docker run behance/docker-aws-secrets-downloader --table $TABLE --key secrets --name GIT_PULL_KEY --format plain | base64 -d`
echo "$GIT_PULL_KEY_CONTENTS" > ${HOMEDIR}/.ssh/id_rsa

# Check to see if the key has a "part 2"
if [[ $AV_SECRETS == *"GIT_PULL_KEY_PART_2"* ]]; then
    GIT_PULL_KEY_CONTENTS_PART_TWO=`sudo docker run behance/docker-aws-secrets-downloader --table $TABLE --key secrets --name GIT_PULL_KEY_PART_2 --format plain | base64 -d`
    echo "$GIT_PULL_KEY_CONTENTS_PART_TWO" >> ${HOMEDIR}/.ssh/id_rsa
fi

sudo chown -R ${OWNER}:${OWNER} ${HOMEDIR}/.ssh/id_rsa
chmod 600 ${HOMEDIR}/.ssh/id_rsa

# ensure that we have a public key for our RSA key and that it's authorized
if [ -f ${HOMEDIR}/.ssh/id_rsa ]; then
    ssh-keygen -f ${HOMEDIR}/.ssh/id_rsa -y > ${HOMEDIR}/.ssh/id_rsa.pub
    cat ${HOMEDIR}/.ssh/id_rsa.pub >> ${HOMEDIR}/.ssh/authorized_keys
fi

# ignore requests against github.com
# TODO: maybe...re-evaluate this
echo -e "Host github.com\n\tStrictHostKeyChecking no\n" > ${HOMEDIR}/.ssh/config
