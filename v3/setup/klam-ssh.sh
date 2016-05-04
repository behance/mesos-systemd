#!/bin/bash -xe

AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
REGION=${AZ::-1}
ROLE_NAME="$(etcdctl get /klam-ssh/config/role-name)"
ENCRYPTION_ID="$(etcdctl get /klam-ssh/config/encryption-id)"
ENCRYPTION_KEY="$(etcdctl get /klam-ssh/config/encryption-key)"
KEY_LOCATION_PREFIX="$(etcdctl get /klam-ssh/config/key-location-prefix)"
IMAGE="$(etcdctl get /images/klam-ssh)"
: ${IMAGE:="adobecloudops/klam-ssh:latest"}


case $REGION in
  "eu-west-1")
    KEY_LOCATION="-ew1" ;;
  "ap-northeast-1")
    KEY_LOCATION="-an1" ;;
  "us-east-1")
    KEY_LOCATION="-ue1" ;;
  "us-west-1")
    KEY_LOCATION="-uw1" ;;
  "us-west-2")
    KEY_LOCATION="-uw2" ;;
  *)
    echo "An incorrect region value specified"
    exit 1
    ;;
esac

# create nsswitch.conf
cat << EOT >> /home/core/nsswitch.conf
passwd:     files usrfiles ato
shadow:     files usrfiles ato
group:      files usrfiles ato

hosts:      files usrfiles dns
networks:   files usrfiles dns

services:   files usrfiles
protocols:  files usrfiles
rpc:        files usrfiles

ethers:     files
netmasks:   files
netgroup:   nisplus
bootparams: files
automount:  files nisplus
aliases:    files nisplus
EOT

# create klam-ssh.conf
cat << EOT >> /home/core/klam-ssh.conf
{
    key_location: ${KEY_LOCATION_PREFIX}${KEY_LOCATION},
    role_name: ${ROLE_NAME},
    encryption_id: ${ENCRYPTION_ID},
    encryption_key: ${ENCRYPTION_KEY},
    resource_location: amazon,
    time_skew: permissive,
    s3_region: ${REGION}
}
EOT

# Create directory structure
mkdir -p /opt/klam/lib /opt/klam/lib64 /etc/ld.so.conf.d

# Docker volume mount
docker create --name klam-ssh ${IMAGE}

# Copy libnss_ato library
docker cp klam-ssh:/tmp/klam-build/coreos/libnss_ato.so.2 /opt/klam/lib64

# Create symlink
ln -sf /opt/klam/lib64/libnss_ato.so.2 /opt/klam/lib64/libnss_ato.so

# Docker remove container
docker rm klam-ssh

# Move the ld.so.conf file to the correct location
echo "/opt/klam/lib64" > /etc/ld.so.conf.d/klam.conf
ldconfig
ldconfig -p | grep klam

# Validate that the files exist in the correct folder
ls -l /opt/klam/lib64/libnss_ato.so*

# Create the klamfed home directory
useradd -p "*" -U -G sudo -u 5000 -m klamfed -s /bin/bash
mkdir -p /home/klamfed
usermod -p "*" klamfed
usermod -U klamfed
update-ssh-keys -u klamfed

# Add klamfed to wheel
usermod -a -G wheel klamfed

# Add klamfed to sudo
usermod -a -G sudo klamfed

# Add passwordless sudo to klamfed
echo "klamfed ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/klamfed

# Validate that the klamfed user has the correct uid value (5000) and home directory
id klamfed
ls -ld /home/klamfed

# Re-link nsswitch.conf
mv -f /home/core/nsswitch.conf /etc/nsswitch.conf
cat /etc/nsswitch.conf

# generate the ATO config
grep klamfed /etc/passwd > /opt/klam/lib/klam-ato.conf

# Validate that the contents of /opt/klam/lib/klam-ato.conf
cat /opt/klam/lib/klam-ato.conf

# Move klam-ssh.conf
mv -f /home/core/klam-ssh.conf /opt/klam/lib/klam-ssh.conf
cat /opt/klam/lib/klam-ssh.conf

#  update /etc/ssh/sshd_config
cp /etc/ssh/sshd_config sshd_config
echo 'AuthorizedKeysCommand /opt/klam/lib/authorizedkeys_command.sh' >> sshd_config
echo 'AuthorizedKeysCommandUser root' >> sshd_config
mv -f sshd_config /etc/ssh/sshd_config
cat /etc/ssh/sshd_config

# Change ownership of authorizedkeys_command
chown root:root /home/core/mesos-systemd/v3/util/authorizedkeys_command.sh

# Relocate authorizedkeys_command
mv /home/core/mesos-systemd/v3/util/authorizedkeys_command.sh /opt/klam/lib

# Change ownership of downloadS3
chown root:root /home/core/mesos-systemd/v3/util/downloadS3.sh

# Relocate downloadS3.sh
mv /home/core/mesos-systemd/v3/util/downloadS3.sh /opt/klam/lib

# Restart SSHD
systemctl restart sshd.service

echo "KLAM SSH BOOTSTRAP COMPLETE"
