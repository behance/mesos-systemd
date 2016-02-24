#!/bin/bash

source /etc/environment
echo "export DOCKER_HOST=tcp://$(eval echo $COREOS_PRIVATE_IPV4):9998" >> /etc/environment
echo "export DOCKER_TLS_VERIFY=1" >> /etc/environment