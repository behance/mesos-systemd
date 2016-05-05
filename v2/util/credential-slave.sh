#!/bin/bash

source /etc/environment

HOMEDIR=$(eval echo "~`whoami`")

principalslave=$(etcdctl get principalslave)
secretslave=$(etcdctl get secretslave)

mkdir $HOMEDIR/mesos-slave
touch $HOMEDIR/mesos-slave/passwd



echo "$(eval echo $principalslave) $(eval echo $secretslave)" > $HOMEDIR/mesos-slave/passwd
