#!/bin/bash

export HISTCONTROL=ignoreboth:erasedups
# get the zone from meta-data
if [[ -z $ZONE ]]; then
    ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
fi

# set the prompt for non-root users
if [[ ${EUID} != 0 ]]; then
  source /etc/environment
  export PS1="\[\\033[01;32m\]$(who -m | awk '{print $1}')@\h\[\\033[01;34m\] \[\\033[01;30m\]$NODE_TIER-$NODE_PRODUCT-$ZONE-$NODE_ROLE \[\\033[01;34m\]\w \$\[\\033[00m\] "
fi
