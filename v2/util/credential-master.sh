#!/bin/bash

source /etc/environment

HOMEDIR=$(eval echo "~`whoami`")

principal=$(etcdctl get principal)
secret=$(etcdctl get secret)
principal1framework=$(etcdctl get principal1framework)
secret1framework=$(etcdctl get secret1framework)

mkdir $HOMEDIR/mesos-master
touch $HOMEDIR/mesos-master/passwd



echo "$(eval echo $principal) $(eval echo $secret)" > $HOMEDIR/mesos-master/passwd
echo "$(eval echo $principal1framework) $(eval echo $secret1framework)" >> $HOMEDIR/mesos-master/passwd
