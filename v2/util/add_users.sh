#!/bin/bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

USERS_DIRECTORY=$1

USAGE_MESSAGE="Please provide a directory of users to add."

if [[ ! $1 ]]; then
  echo "$USAGE_MESSAGE"
  exit 1;
fi

# Remove trailing slash
USERS_DIRECTORY=${USERS_DIRECTORY%/}

if [[ -d "$USERS_DIRECTORY" ]]; then
  for user in $USERS_DIRECTORY/*.pub; do
    username=$(basename ${user%.*})
    echo "Adding user $username"

    sudo useradd -p "*" -U -m $username -G sudo,docker
    sudo update-ssh-keys -u $username -a $username $user
    sudo /bin/bash ${SCRIPTDIR}/v2/setup/twistlockclientcert.sh
  done

  exit 0;
else
  echo "$USAGE_MESSAGE"
  exit 1;
fi
