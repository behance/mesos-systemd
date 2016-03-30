#!/bin/bash

source /etc/environment

HOMEDIR=$(eval echo "~`whoami`")

principal=$(etcdctl get principal)
secret=$(etcdctl get secret)

mkdir $HOMEDIR/mesos-master
touch $HOMEDIR/mesos-master/passwd



echo "$(eval echo $principal) $(eval echo $secret)" > $HOMEDIR/mesos-master/passwd
