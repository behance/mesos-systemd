#!/usr/bin/bash -xe

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOMEDIR=$(eval echo "~`whoami`")
OWNER=$(whoami)

source /etc/environment

# On the worker tier, the containers need to be launched with a role
# because of the IAM proxy metadata service.
IAM_ROLE_LABEL=""

if [[ "${NODE_ROLE}" = "worker" && ! -z "$CONTAINERS_ROLE" ]]; then
    IAM_ROLE_LABEL=' --label com.swipely.iam-docker.iam-profile='"$CONTAINERS_ROLE"' '
fi

TABLE=`sudo echo $SECRETS_TABLE`
docker pull behance/docker-aws-secrets-downloader:latest

# Create a dockercfg
DOCKERCFG_CONTENTS=`sudo docker run --log-opt max-size=10m --log-opt max-file=10 --rm $IAM_ROLE_LABEL behance/docker-aws-secrets-downloader --table $TABLE --key secrets --name DOCKERCFG --format plain`
echo "$DOCKERCFG_CONTENTS" > /home/${OWNER}/.dockercfg
sudo chown -R ${OWNER}:${OWNER} /home/${OWNER}/.dockercfg
sudo cp /home/${OWNER}/.dockercfg /root/.dockercfg

# Actually generate a private key
ssh-keygen -f ${HOMEDIR}/.ssh/id_rsa -t rsa -N ''
# ensure that we have a public key for our RSA key and that it's authorized
ssh-keygen -f ${HOMEDIR}/.ssh/id_rsa -y > ${HOMEDIR}/.ssh/id_rsa.pub
cat ${HOMEDIR}/.ssh/id_rsa.pub >> ${HOMEDIR}/.ssh/authorized_keys

AV_SECRETS=`sudo docker run --rm --log-opt max-size=10m --log-opt max-file=10 $IAM_ROLE_LABEL behance/docker-aws-secrets-downloader --table $TABLE --key secrets`

# Save the RDS password to environment variable in control tier
# TODO: :(
if [[ "$NODE_ROLE" = "control" && $AV_SECRETS == *"RDSPASSWORD"* ]]; then
    RDSPASSWORD=`sudo docker run --log-opt max-size=10m --log-opt max-file=10 --rm $IAM_ROLE_LABEL behance/docker-aws-secrets-downloader --table $TABLE --key secrets --name RDSPASSWORD --format plain`
    etcdctl set /environment/RDSPASSWORD $RDSPASSWORD
fi

# ignore requests against github.com
# TODO: maybe...re-evaluate this
echo -e "Host github.com\n\tStrictHostKeyChecking no\n" > ${HOMEDIR}/.ssh/config
