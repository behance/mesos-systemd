#!/bin/bash
source /etc/environment
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
REGION=${AZ::-1}

# Variable assignment based on REGION and service specific environments
case $NODE_TIER in
        "stage")
            ROLE_NAME="$(etcdctl get /environment/KLAM_SSH_ROLE_NAME)"
            ENCRYPTION_KEY_ID="<ENCRYPTION_KEY_ID>"
            ENCRYPTION_SECRET="<ENCRYPTION_SECRET>"
            if [[ $REGION == "eu-west-1" ]]; then
                KLAM_SSH_KEY_LOCATION="adobe-cloudops-ssh-users-ew1"
            elif [[ $REGION == "ap-northeast-1" ]]; then
                KLAM_SSH_KEY_LOCATION="adobe-cloudops-ssh-users-an1"
            elif [[ $REGION == "us-east-1" ]]; then
                KLAM_SSH_KEY_LOCATION="adobe-cloudops-ssh-users-ue1"
            elif [[ $REGION == "us-west-1" ]]; then
                KLAM_SSH_KEY_LOCATION="adobe-cloudops-ssh-users-uw1"
            elif [[ $REGION == "us-west-2" ]]; then
                KLAM_SSH_KEY_LOCATION="adobe-cloudops-ssh-users-uw2"
            else
                echo "An incorrect region value specified"
            fi
            ;;
        "production")
            ROLE_NAME="$(etcdctl get /environment/KLAM_SSH_ROLE_NAME)"
            ENCRYPTION_KEY_ID="<ENCRYPTION_KEY_ID>"
            ENCRYPTION_SECRET="<ENCRYPTION_SECRET>"
            if [[ $REGION == "eu-west-1" ]]; then
                KLAM_SSH_KEY_LOCATION="adobe-cloudops-ssh-users-ew1"
            elif [[ $REGION == "ap-northeast-1" ]]; then
                KLAM_SSH_KEY_LOCATION="adobe-cloudops-ssh-users-an1"
            elif [[ $REGION == "us-east-1" ]]; then
                KLAM_SSH_KEY_LOCATION="adobe-cloudops-ssh-users-ue1"
            elif [[ $REGION == "us-west-1" ]]; then
                KLAM_SSH_KEY_LOCATION="adobe-cloudops-ssh-users-uw1"
            elif [[ $REGION == "us-west-2" ]]; then
                KLAM_SSH_KEY_LOCATION="adobe-cloudops-ssh-users-uw2"
            else
                echo "An incorrect region value specified"
            fi
            ;;
        "dev")
            ROLE_NAME="$(etcdctl get /environment/KLAM_SSH_ROLE_NAME)"
            ENCRYPTION_KEY_ID="<ENCRYPTION_KEY_ID>"
            ENCRYPTION_SECRET="<ENCRYPTION_SECRET>"
            if [[ $REGION == "eu-west-1" ]]; then
                KLAM_SSH_KEY_LOCATION="adobe-cloudops-ssh-users-ew1"
            elif [[ $REGION == "ap-northeast-1" ]]; then
                KLAM_SSH_KEY_LOCATION="adobe-cloudops-ssh-users-an1"
            elif [[ $REGION == "us-east-1" ]]; then
                KLAM_SSH_KEY_LOCATION="adobe-cloudops-ssh-users-ue1"
            elif [[ $REGION == "us-west-1" ]]; then
                KLAM_SSH_KEY_LOCATION="adobe-cloudops-ssh-users-uw1"
            elif [[ $REGION == "us-west-2" ]]; then
                KLAM_SSH_KEY_LOCATION="adobe-cloudops-ssh-users-uw2"
            else
                echo "An incorrect region value specified"
            fi
            ;;
        "sandbox")
            ROLE_NAME="$(etcdctl get /environment/KLAM_SSH_ROLE_NAME)"
            ENCRYPTION_KEY_ID="touKXAyAsM9udkGq"
            ENCRYPTION_SECRET="YhbJDp3Joqlh0oVJi8avwZbF9c7a6VT0"
            if [[ $REGION == "eu-west-1" ]]; then
                KLAM_SSH_KEY_LOCATION="adobe-cloudops-ssh-users-ew1"
            elif [[ $REGION == "ap-northeast-1" ]]; then
                KLAM_SSH_KEY_LOCATION="adobe-cloudops-ssh-users-an1"
            elif [[ $REGION == "us-east-1" ]]; then
                KLAM_SSH_KEY_LOCATION="adobe-cloudops-ssh-users-ue1"
            elif [[ $REGION == "us-west-1" ]]; then
                KLAM_SSH_KEY_LOCATION="adobe-cloudops-ssh-users-uw1"
            elif [[ $REGION == "us-west-2" ]]; then
                KLAM_SSH_KEY_LOCATION="adobe-cloudops-ssh-users-uw2"
            else
                echo "An incorrect region value specified"
            fi
            ;;
        "private")
            ROLE_NAME="klam-user-ssh-cloudops-laserunicorn-all-sts"
            ENCRYPTION_KEY_ID="ie5k1w03wWzF8b123H"
            ENCRYPTION_SECRET="WRaCMt13I2D123SnjG4G"
            if [[ $REGION == "eu-west-1" ]]; then
                KLAM_SSH_KEY_LOCATION="adobe-cloudops-ssh-users-ew1"
            elif [[ $REGION == "ap-northeast-1" ]]; then
                KLAM_SSH_KEY_LOCATION="adobe-cloudops-ssh-users-an1"
            elif [[ $REGION == "us-east-1" ]]; then
                KLAM_SSH_KEY_LOCATION="adobe-cloudops-ssh-users-ue1"
            elif [[ $REGION == "us-west-1" ]]; then
                KLAM_SSH_KEY_LOCATION="adobe-cloudops-ssh-users-uw1"
            elif [[ $REGION == "us-west-2" ]]; then
                KLAM_SSH_KEY_LOCATION="adobe-cloudops-ssh-users-uw2"
            else
                echo "An incorrect region value specified"
            fi
            ;;
        *)
            echo $"Usage: Both ENV and REGION values must be specified"
            exit 1
esac

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
echo "    \"key_location\": \"$KLAM_SSH_KEY_LOCATION\"," >> /home/core/klam-ssh.conf
echo "    \"role_name\": \"$ROLE_NAME\"," >> /home/core/klam-ssh.conf
echo "    \"encryption_id\": \"$ENCRYPTION_KEY_ID\"," >> /home/core/klam-ssh.conf
echo "    \"encryption_key\": \"$ENCRYPTION_SECRET\"," >> /home/core/klam-ssh.conf
echo "    \"resource_location\": \"amazon\"," >> /home/core/klam-ssh.conf
echo "    \"time_skew\": \"permissive\"," >> /home/core/klam-ssh.conf
echo "    \"s3_region\": \"$REGION\"" >> /home/core/klam-ssh.conf
echo "}" >> /home/core/klam-ssh.conf

# Use sudo to become root
sudo su - <<RUN_AS_ROOT

# Create directory structure
mkdir -p /opt/klam/lib /opt/klam/lib64 /etc/ld.so.conf.d /tmp/klam-installer

# Download and install the PAM package
cd /tmp/klam-installer && wget https://s3.amazonaws.com/adobe-cloudops-ssh-users/klam-ssh-installer/remote-instances/libnss_ato_amazon.tar.gz -O libnss_ato.tar.gz

# Unpack the package and move files around
cd /tmp/klam-installer
tar -xvzf libnss_ato.tar.gz
rm -f -r /opt/klam/lib/*
mv usr/lib/klam/* /opt/klam/lib/
chown -R root. /opt/klam/lib/

# Move the libnss_ato libraries to the correct location
ls -alh /tmp/klam-installer
mv -f /tmp/klam-installer/lib64/* /opt/klam/lib64/

# Move the ld.so.conf file to the correct location
echo "/opt/klam/lib64" > /etc/ld.so.conf.d/klam.conf
ldconfig
ldconfig -p | grep klam

# Validate that the files exist in the correct folder
ls -l /opt/klam/lib64/libnss_ato.so*

# Delete the /tmp/klam-installer
cd / && rm -rf /tmp/klam-installer

# Check the contents of /usr/lib/klam and it should look similar to the following
ls -l /opt/klam/lib/

# Create the klamfed home directory
useradd -p "*" -U -G sudo -u 5000 -m klamfed -s /bin/bash
mkdir -p /home/klamfed
usermod -p "*" klamfed
usermod -U klamfed
update-ssh-keys -u klamfed

# Add klamfed to wheel
usermod -a -G wheel klamfed

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
echo 'AuthorizedKeysCommand /opt/klam/lib/authorizedkeys-command.sh %u' >> sshd_config
echo 'AuthorizedKeysCommandUser root' >> sshd_config
mv -f sshd_config /etc/ssh/sshd_config
cat /etc/ssh/sshd_config
echo ""

# Set up AuthorizedKeysCommand
echo '#!/bin/bash' >> /opt/klam/lib/authorizedkeys-command.sh
echo 'docker run --rm -e KLAM_SSH_ROLE_NAME=ethos-sandbox-all-sts -e KLAM_SSH_ENCRYPTION_ID=touKXAyAsM9udkGq -e KLAM_SSH_ENCRYPTION_KEY=YhbJDp3Joqlh0oVJi8avwZbF9c7a6VT0 eadasiak/klam-ssh:0.4 /usr/lib/klam/getKeys.py $1' >> /opt/klam/lib/authorizedkeys-command.sh
echo 'exit 0' >> /opt/klam/lib/authorizedkeys-command.sh
chmod 755 /opt/klam/lib/authorizedkeys-command.sh

# Set up downloadS3 command
echo '#!/bin/bash' >> /opt/klam/lib/downloadS3.sh
echo 'docker run --rm -e KLAM_SSH_ROLE_NAME=ethos-sandbox-all-sts -e KLAM_SSH_ENCRYPTION_ID=touKXAyAsM9udkGq -e KLAM_SSH_ENCRYPTION_KEY=YhbJDp3Joqlh0oVJi8avwZbF9c7a6VT0 eadasiak/klam-ssh:0.4 /usr/lib/klam/downloadS3.py' >> /opt/klam/lib/downloadS3.sh
echo 'exit 0' >> /opt/klam/lib/downloadS3.sh
chmod 755 /opt/klam/lib/downloadS3.sh

# Restart SSHD
systemctl restart sshd.service
RUN_AS_ROOT

echo "KLAM SSH BOOTSTRAP COMPLETE"
