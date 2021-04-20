#!/usr/bin/env zsh

set -euo pipefail

SCRIPT_PATH=${0:A:h}
ENV_PATH="${SCRIPT_PATH}/../src/xcode/ENA/ENA/Resources/Environment/Environments.json"

# fetch CI configuration and overwrite local environments file
curl \
  --header "Authorization: token ${GITHUB_ACCESS_TOKEN}" \
  --header "Accept: application/vnd.github.v3.raw" \
  --silent \
  --fail \
  --remote-name \
  --output "${ENV_PATH}" \
  --location "${ENVIRONMENTS_FILE_URL}"
