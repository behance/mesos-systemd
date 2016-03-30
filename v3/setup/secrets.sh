#!/bin/bash

declare -A SECRETMAP

SECRETMAP[DATADOG_KEY]="/ddapikey"
SECRETMAP[FD_GITHUB_CLIENT_ID]="/FD/GITHUB_CLIENT_ID"
SECRETMAP[FD_GITHUB_CLIENT_SECRET]="/FD/GITHUB_CLIENT_SECRET"
SECRETMAP[FD_GITHUB_ALLOWED_TEAMS]="/FD/GITHUB_ALLOWED_TEAMS"
SECRETMAP[HUD_GITHUB_CLIENT_ID]="/HUD/client-id"
SECRETMAP[HUD_GITHUB_CLIENT_SECRET]="/HUD/client-secret"
SECRETMAP[MARATHON_USERNAME]="/marathon/username"
SECRETMAP[MARATHON_PASSWORD]="/marathon/password"
SECRETMAP[SUMOLOGIC_ACCESS_ID]="/sumologic_id"
SECRETMAP[SUMOLOGIC_SECRET]="/sumologic_secret"
SECRETMAP[SYSDIG_KEY]="/sysdigkey"
SECRETMAP[SYSDIG_KEY]="/zookeeper/ZK_USERNAME"
SECRETMAP[SYSDIG_KEY]="/zookeeper/ZK_PASSWORD"
SECRETMAP[SYSDIG_KEY]="principal"
SECRETMAP[SYSDIG_KEY]="secret"
SECRETMAP[SYSDIG_KEY]="principalslave"
SECRETMAP[SYSDIG_KEY]="secretslave"

TABLE=`sudo echo $SECRETS_TABLE`

docker pull behance/docker-aws-secrets-downloader:latest

for K in "${!SECRETMAP[@]}"; do
        PLAINTEXT=`sudo docker run behance/docker-aws-secrets-downloader --table $TABLE --name $K`
        etcdctl set ${SECRETMAP[$K]} $PLAINTEXT &>/dev/null
done