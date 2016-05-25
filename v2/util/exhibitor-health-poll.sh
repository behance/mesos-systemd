#!/usr/bin/bash -x

while [ "`systemctl is-active zk-exhibitor@*`" != "active" ]; do sleep 2; done

ZK_AUTH="zk:`etcdctl get /zookeeper/ZK_PASSWORD`"
# array of objects, each representing a ZK node
EX_QUERY="curl -sS ${ZK_AUTH}@localhost:8181/exhibitor/v1/cluster/status"
# expected size of ensemble after it's done
CTL_SIZE="`etcdctl get /zookeeper/ensemble_size`"

# code==3 means that the node is up and serving
while [ "`$EX_QUERY|jq '[select(.[].code == 3)]|length'`" != "$CTL_SIZE" ]; do sleep 4; done
