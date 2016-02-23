#!/bin/bash
source /etc/environment
/usr/bin/bash /home/core/mesos-systemd/v2/util/twistlockclientcert.sh

for i in `ls /home`;

  do sudo cp -rf /home/core/.docker /home/$i


done
