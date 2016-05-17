#!/bin/bash -x

etcdctl set /etcdctl/config/root-user root
etcdctl set /etcdctl/config/read-user read-user
etcdctl set /etcdctl/config/write-user write-user

ROOT_USERNAME=$(etcdctl get /etcdctl/config/root-user)
ROOT_PASSWORD=$(etcdctl get /etcdctl/config/root-password)
READ_USERNAME=$(etcdctl get /etcdctl/config/read-user)
READ_PASSWORD=$(etcdctl get /etcdctl/config/read-password)
WRITE_USERNAME=$(etcdctl get /etcdctl/config/write-user)
WRITE_PASSWORD=$(etcdctl get /etcdctl/config/write-password)

CRED_DIR="/opt/etcdctl"
if [[ ! -d $CRED_DIR ]]; then
    sudo mkdir $CRED_DIR -p
fi

sudo chown -R $(whoami):$(whoami) $CRED_DIR

# add root-user
sudo echo '{"user":"'${ROOT_USERNAME}'", "password":"'${ROOT_PASSWORD}'"}' > $CRED_DIR/root-user.json
curl -L http://127.0.0.1:2379/v2/auth/users/${ROOT_USERNAME} -XPUT -d "@$CRED_DIR/root-user.json"

# add read-user
sudo echo '{"user":"'${READ_USERNAME}'", "password":"'${READ_PASSWORD}'"}' > $CRED_DIR/read-user.json
curl -L http://127.0.0.1:2379/v2/auth/users/${READ_USERNAME} -XPUT -d "@$CRED_DIR/read-user.json"

# add write-user
sudo echo '{"user":"'${WRITE_USERNAME}'", "password":"'${WRITE_PASSWORD}'"}' > $CRED_DIR/write-user.json
curl -L http://127.0.0.1:2379/v2/auth/users/${WRITE_USERNAME} -XPUT -d "@$CRED_DIR/write-user.json"

# read access
etcdctl role add read-only
etcdctl role grant read-only -path '/*' -read

# write access
etcdctl role add read-write
etcdctl role grant read-write -path '/*' -readwrite

# Give read-user read access
sudo echo '{"user": "'${READ_USERNAME}'", "grant": ["read-only"]}' > $CRED_DIR/read-only.json
curl -L http://127.0.0.1:2379/v2/auth/users/${READ_USERNAME} -XPUT -d "@$CRED_DIR/read-only.json"

# Give read-write write access
sudo echo '{"user": "'${WRITE_USERNAME}'", "grant": ["read-write"]}' > $CRED_DIR/read-write.json
curl -L http://127.0.0.1:2379/v2/auth/users/${WRITE_USERNAME} -XPUT -d "@$CRED_DIR/read-write.json"

# Enable authentication
curl -L http://127.0.0.1:2379/v2/auth/enable -XPUT

sudo rm -rf $CRED_DIR
