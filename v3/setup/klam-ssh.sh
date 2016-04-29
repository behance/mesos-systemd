#!/bin/bash

AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
REGION=${AZ::-1}
ROLE_NAME="$(etcdctl get /klam-ssh/ROLE_NAME)"
ENCRYPTION_ID="$(etcdctl get /klam-ssh/ENCRYPTION_ID)"
ENCRYPTION_KEY="$(etcdctl get /klam-ssh/ENCRYPTION_KEY)"
KEY_LOCATION_PREFIX="$(etcdctl get /klam-ssh/KEY_LOCATION_PREFIX)"
IMAGE="$(etcdctl get /images/klam-ssh)"


if [[ $REGION == "eu-west-1" ]]; then
    KEY_LOCATION="-ew1"
elif [[ $REGION == "ap-northeast-1" ]]; then
    KEY_LOCATION="-an1"
elif [[ $REGION == "us-east-1" ]]; then
    KEY_LOCATION="-ue1"
elif [[ $REGION == "us-west-1" ]]; then
    KEY_LOCATION="-uw1"
elif [[ $REGION == "us-west-2" ]]; then
    KEY_LOCATION="-uw2"
else
    echo "An incorrect region value specified"
    exit 1
fi

# create nsswitch.conf
echo "passwd:     files usrfiles ato" > /home/core/nsswitch.conf
echo "shadow:     files usrfiles ato" >> /home/core/nsswitch.conf
echo "group:      files usrfiles ato" >> /home/core/nsswitch.conf
echo -e "\n" >> /home/core/nsswitch.conf
echo "hosts:      files usrfiles dns" >> /home/core/nsswitch.conf
echo "networks:   files usrfiles dns" >> /home/core/nsswitch.conf
echo -e "\n" >> /home/core/nsswitch.conf
echo "services:   files usrfiles" >> /home/core/nsswitch.conf
echo "protocols:  files usrfiles" >> /home/core/nsswitch.conf
echo "rpc:        files usrfiles" >> /home/core/nsswitch.conf
echo -e "\n" >> /home/core/nsswitch.conf
echo "ethers:     files" >> /home/core/nsswitch.conf
echo "netmasks:   files" >> /home/core/nsswitch.conf
echo "netgroup:   nisplus" >> /home/core/nsswitch.conf
echo "bootparams: files" >> /home/core/nsswitch.conf
echo "automount:  files nisplus" >> /home/core/nsswitch.conf
echo "aliases:    files nisplus" >> /home/core/nsswitch.conf

# create klam-ssh.conf
echo "{" > /home/core/klam-ssh.conf
echo "    \"key_location\": \"${KEY_LOCATION_PREFIX}${KEY_LOCATION}\"," >> /home/core/klam-ssh.conf
echo "    \"role_name\": \"${ROLE_NAME}\"," >> /home/core/klam-ssh.conf
echo "    \"encryption_id\": \"${ENCRYPTION_ID}\"," >> /home/core/klam-ssh.conf
echo "    \"encryption_key\": \"${ENCRYPTION_KEY}\"," >> /home/core/klam-ssh.conf
echo "    \"resource_location\": \"amazon\"," >> /home/core/klam-ssh.conf
echo "    \"time_skew\": \"permissive\"," >> /home/core/klam-ssh.conf
echo "    \"s3_region\": \"${REGION}\"" >> /home/core/klam-ssh.conf
echo "}" >> /home/core/klam-ssh.conf

# Create directory structure
mkdir -p /opt/klam/lib /opt/klam/lib64 /etc/ld.so.conf.d

# Docker volume mount
docker run --name klam-ssh -v /opt/klam/lib64:/data ${IMAGE}

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
echo ""

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
