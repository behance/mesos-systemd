#!/bin/bash

# Use meta-data to determine the public IPv4 of this bastion host and the vpc's cidr block
IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
ETH0_MAC=$(ifconfig eth0 | grep ether | awk '{print tolower($2)}')
VPC_CIDR=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/${ETH0_MAC}/vpc-ipv4-cidr-block)

# Split the network IP from the mask and assign them to separate variables
IFS='/' read -r -a CIDR_ARRAY <<< "${VPC_CIDR}"
NETWORK=${CIDR_ARRAY[0]}
MASK=${CIDR_ARRAY[1]}

# Determine how many /24 networks fit into the given VPC_CIDR.  Yes, this is ugly for two reasons.
# One, ssh_config only allows string pattern matching, so for subnets, one can only use a network
# terminated with a wildcard for the last octet.  Second, there's a limit to the size of the VPC
# that can be allocated in Adobe private address space.  HamCIDR only allows CIDR blocks from /25
# to /22, so any other value is bypassing SOP.  A case statement can't do range comparisons, and
# I didn't want to implement a subnet calculator in BASH, so there's this:

if [[ "${MASK}" -ge 24 ]]; then SUBNETS=1
elif [[ "${MASK}" == 23 ]]; then SUBNETS=2
elif [[ "${MASK}" == 22 ]]; then SUBNETS=4
elif [[ "${MASK}" == 21 ]]; then SUBNETS=8
elif [[ "${MASK}" == 20 ]]; then SUBNETS=16
else
  echo "Your large CIDR block broke teh internets."
  exit 1
fi

# Build the string of /24 networks to use in the ssh_config
HOSTS=$(for ((i = 0; i < ${SUBNETS}; i++)); do echo ${NETWORK} | awk -v x="${i}" -F. '{printf "%d.%d.%d.%s", $1,$2,$3+x,"* "}'; done; echo)


cat << EOF
Host ${IP}
  ForwardAgent yes
  IdentityFile ~/.ssh/ssh.pem

Host ${HOSTS}
  IdentityFile ~/.ssh/ssh.pem
  ProxyCommand ssh ${IP} ncat %h %p
EOF
