#!/bin/bash

source /etc/environment

HOMEDIR=$(eval echo "~`whoami`")

#principal=$(etcdctl get principal)
secretframework=$(etcdctl get /frameworkauth/secret)

mkdir $HOMEDIR/mesos-framework


echo -n "$(eval echo $secretframework)" > $HOMEDIR/mesos-framework/passwd

chmod 0600 /home/core/mesos-framework/passwd
