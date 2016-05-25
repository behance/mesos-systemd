#!/bin/bash -x

source /etc/environment
if [ "${NODE_ROLE}" != "control" ] && [ "${NODE_ROLE}" != "worker"]; then
    exit 0
fi
source /etc/profile.d/etcdctl.sh || :

etcdctl get /mesos/config/password
if [[ $? = 4 ]]; then
    echo "etcd /mesos/config/password NOT SET, NOT CONTINUING"
    exit 1
fi

# ensure that we have sane default for username
etcdctl get /mesos/config/username
if [[ $? = 4 ]]; then
    etcdctl set /mesos/config/username ethos
fi
CREDS="$(etcdctl get /mesos/config/username) $(etcdctl get /mesos/config/password)"

CRED_DIR="/opt/mesos"
if [[ ! -d $CRED_DIR ]]; then
    sudo mkdir $CRED_DIR -p
fi

# primary credentials used by workers & masters
sudo echo "$CREDS" > $CRED_DIR/credentials

if [[ "${NODE_ROLE}" = "control" ]]; then
    # on a control node - set up credentials for registering frameworks
    # (i.e.: marathon & chronos)
    # TODO: have separate credentials for framework vs worker/master
    sudo echo -n "$CREDS" >> $CRED_DIR/credentials
    sudo echo -n "$(etcdctl get /mesos/config/password)" > $CRED_DIR/framework-secret
    sudo chmod 0600 $CRED_DIR/framework-secret
fi

sudo chmod 0600 $CRED_DIR/credentials
sudo chown -R $(whoami):$(whoami) $CRED_DIR
