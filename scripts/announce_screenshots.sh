#!/usr/bin/env zsh

set -euo pipefail

SCREENSHOT_URL=$1

CIRCLE_PROJECT_REPONAME="CWA"
CIRCLE_USERNAME="CIRCLE_USERNAME"
CIRCLE_BRANCH="CIRCLE_BRANCH"
CIRCLE_BUILD_NUM="CIRCLE_BUILD_NUM"

if curl --output /dev/null --silent --head --fail "$SCREENSHOT_URL"; then
  curl --output /dev/null --silent $SAP_TEAMS_WEBHOOK \
  -H 'Content-Type: application/json' \
  --data-binary @- << EOF
{
  "@type": "MessageCard",
  "@context": "http://schema.org/extensions",
  "themeColor": "0076D7",
  "summary": "Fresh screenshots have arrived!",
  "sections": [{
      "activityTitle": "Fresh screenshots have arrived!",
      "activitySubtitle": "On Project ${CIRCLE_PROJECT_REPONAME}",
      "activityImage": "https://media.staticline.de/pictures/530f4962378e781ea8c5f70aa9fbacca535968f2.png",
      "facts": [{
          "name": "Created by",
          "value": "${CIRCLE_USERNAME}"
      }, {
          "name": "Timestamp",
          "value": "$(date "+%Y-%m-%d %H:%M")"
      }, {
          "name": "Branch",
          "value": "${CIRCLE_BRANCH}"
      }, {
          "name": "Build number",
          "value": "${CIRCLE_BUILD_NUM}"
      }],
      "markdown": true
  }],
  "potentialAction": [{
      "@type": "OpenUri",
      "name": "Download now!",
      "targets": [{
          "os": "default",
          "uri": "${SCREENSHOT_URL}"
      }]
  }]
}
EOF
else
  echo "Could not locate screenshots at $SCREENSHOT_URL"
  return 1
fi
