#!/bin/bash

source /etc/environment

HOMEDIR=$(eval echo "~`whoami`")

#principal=$(etcdctl get principal)
secretframework=$(etcdctl get secretframework)

mkdir $HOMEDIR/mesos-framework
touch $HOMEDIR/mesos-framework/passwd



echo -n "$(eval echo $secretframework)" > $HOMEDIR/mesos-framework/passwd
