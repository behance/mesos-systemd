#!/bin/bash

source /etc/environment

HOMEDIR=$(eval echo "~`whoami`")

principalslave=$(etcdctl get /frameworkauth/username)
secretslave=$(etcdctl get /frameworkauth/secret)

mkdir $HOMEDIR/mesos-slave
touch $HOMEDIR/mesos-slave/passwd



echo "$(eval echo $principalslave) $(eval echo $secretslave)" > $HOMEDIR/mesos-slave/passwd
