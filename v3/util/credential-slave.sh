#!/bin/bash

source /etc/environment

HOMEDIR=$(eval echo "~`whoami`")

principalslave=$(etcdctl get /frameworkauth/username)
secretslave=$(etcdctl get /frameworkauth/secret)

mkdir $HOMEDIR/mesos-slave


echo "$(eval echo $principalslave) $(eval echo $secretslave)" > $HOMEDIR/mesos-slave/passwd

chmod 0600 /home/core/mesos-slave/passwd
