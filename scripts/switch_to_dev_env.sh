#!/usr/bin/env zsh

set -euo pipefail

SCRIPT_PATH=${0:A:h}
ENV_PATH=`realpath "${SCRIPT_PATH}/../src/xcode/ENA/ENA/Resources/Environment/Environments.json"`

# fetch CI configuration and overwrite local environments file
curl \
  --header "Authorization: token ${GITHUB_ACCESS_TOKEN}" \
  --header "Accept: application/vnd.github.v3.raw" \
  --silent \
  --fail \
  --location "${ENVIRONMENTS_WRU_FILE_URL}" > ${ENV_PATH}

if [ ! -f ${ENV_PATH} ]; then
  echo "No environment file present. Aborting."
  exit 1
fi
