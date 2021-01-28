#!/usr/bin/env zsh

set -euo pipefail

SCREENSHOT_URL=$1

if curl --output /dev/null --silent --head --fail "$SCREENSHOT_URL"; then
  curl --output /dev/null --silent -H 'Content-Type: application/json' -d '{"text": "[Fresh screenshots have arrived!]('${SCREENSHOT_URL}')"}' $SAP_TEAMS_WEBHOOK
else
  echo "Could not locate screenshots at $SCREENSHOT_URL"
  return 1
fi
