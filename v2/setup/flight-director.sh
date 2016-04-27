#!/bin/bash

source /etc/environment

if [ "${NODE_ROLE}" != "control" ]  && [ "${NODE_ROLE}" != "it-hybrid" ]; then
    exit 0
fi

if [ "$(etcdctl get fd-bootstrapped)" == "true" ]; then
    exit 0
fi
etcdctl set fd-bootstrapped true

etcdctl setdir FD
etcdctl set /FD/FD_API_SERVER_PORT 2001
etcdctl set /FD/FD_CHRONOS_MASTER "$FLIGHT_DIRECTOR_CHRONOS_ENDPOINT"
etcdctl set /FD/FD_DB_DATABASE "$FLIGHT_DIRECTOR_DB_NAME"
etcdctl set /FD/FD_DB_ENGINE mysql
etcdctl set /FD/FD_DB_PASSWORD "$FLIGHT_DIRECTOR_DB_PASSWORD"
etcdctl set /FD/FD_DB_PATH "$FLIGHT_DIRECTOR_DB_PATH"
etcdctl set /FD/FD_DB_USERNAME "$FLIGHT_DIRECTOR_DB_USERNAME"
etcdctl set /FD/FD_DOCKERCFG_LOCATION file:///root/.dockercfg
etcdctl set /FD/FD_DEBUG false
etcdctl set /FD/FD_EVENT_INTERFACE ''
etcdctl set /FD/FD_EVENT_PORT 2001
etcdctl set /FD/FD_FIXTURES "$FLIGHT_DIRECTOR_FIXTURES"
etcdctl set /FD/FD_KV_SERVER http://localhost:2379
etcdctl set /FD/FD_LOG_LEVEL "$FLIGHT_DIRECTOR_LOG_LEVEL"
etcdctl set /FD/FD_LOG_LOCATION "$FLIGHT_DIRECTOR_LOG_LOCATION"
etcdctl set /FD/FD_LOG_MARATHON_API_CALLS false
etcdctl set /FD/FD_MARATHON_MASTER "$FLIGHT_DIRECTOR_MARATHON_ENDPOINT"
etcdctl set /FD/FD_MESOS_MASTER "$FLIGHT_DIRECTOR_MESOS_ENDPOINT"
etcdctl get /FD/FD_MARATHON_MASTER_PROTOCOL http
etcdctl get /FD/FD_ALLOW_MARATHON_UNVERIFIED_TLS false

etcdctl set /FD/AUTHORIZER_TYPE airlock
etcdctl set /FD/GITHUB_TOKEN_URL https://github.com/login/oauth/access_token
etcdctl set /FD/GITHUB_API https://api.github.com
etcdctl set /FD/GITHUB_CLIENT_ID ''
etcdctl set /FD/GITHUB_CLIENT_SECRET ''
etcdctl set /FD/GITHUB_ALLOWED_TEAMS ''


HOMEDIR=$(eval echo "~`whoami`")

AWS_CREDS=""
if [ ! -z $AWS_ACCESS_KEY ]; then
    AWS_CREDS=" -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY \
     -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY "
fi

sudo docker run --rm \
    -v ${HOMEDIR}:/data/ $AWS_CREDS behance/docker-aws-s3-downloader \
     us-east-1 $CONTROL_TIER_S3SECURE_BUCKET .flight-director

# it's expected that these fields are already in the form
# /KEY/NAMESPACE VALUE

# To edit the fields in .flight-director:
# 1) Download the current version of .flight-director from S3: be-secure-<tier>/.flight-director
# 2) Edit this file locally
# 3) Verify changes with peers
# 4) Upload edited file back to S3: be-secure-tier/.flight-director
# 5) Restart flight-director fleet-units via jenkins for changes to take effect



printf "#!/bin/bash\nsource /etc/environment\n" >  ${HOMEDIR}/.fd_runnable.sh
while read line || [[ -n "$line" ]]; do
    printf "etcdctl set $line \n" >> ${HOMEDIR}/.fd_runnable.sh
done < ${HOMEDIR}/.flight-director
chmod +x ${HOMEDIR}/.fd_runnable.sh
${HOMEDIR}/.fd_runnable.sh
rm ${HOMEDIR}/.fd_runnable.sh
