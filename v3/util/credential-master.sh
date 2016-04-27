#!/bin/bash

source /etc/environment

HOMEDIR=$(eval echo "~`whoami`")

principal=$(etcdctl get /frameworkauth/username)
secret=$(etcdctl get /frameworkauth/secret)
principal1framework=$(etcdctl get /frameworkauth/username)
secret1framework=$(etcdctl get /frameworkauth/secret)

mkdir $HOMEDIR/mesos-master



echo "$(eval echo $principal) $(eval echo $secret)" > $HOMEDIR/mesos-master/passwd
echo "$(eval echo $principal1framework) $(eval echo $secret1framework)" >> $HOMEDIR/mesos-master/passwd
chmod 0600 /home/core/mesos-master/passwd
