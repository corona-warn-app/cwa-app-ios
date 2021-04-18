#!/usr/bin/env zsh

set -euo pipefail

SCRIPT_PATH=${0:A:h}
ENV_PATH="${SCRIPT_PATH}/../src/xcode/ENA/ENA/Resources/Environment/Environments.test.json"

# Fetch CI configuration
curl \
  --header "Authorization: token ${GITHUB_ACCESS_TOKEN}" \
  --header "Accept: application/vnd.github.v3.raw" \
  --remote-name \
  --location "${ENVIRONMENTS_DOWNLOAD_URL}${ENV_PROP_DOWNLOAD_FILENAME}" > ${ENV_PATH}
