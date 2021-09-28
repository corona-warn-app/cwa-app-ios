#!/usr/bin/env zsh

set -euo pipefail

SCREENSHOT_URL=$1

if ! [[curl --output /dev/null --silent --head --fail "$SCREENSHOT_URL"]]; then
  curl --output /dev/null --silent $Failed_SCREENSHOTS_TEAMS \
  -H 'Content-Type: application/json' \
  --data-binary @- << EOF
{
  "@type": "MessageCard",
  "@context": "http://schema.org/extensions",
  "themeColor": "0076D7",
  "summary": "screenshots have failed!",
  "sections": [{
      "activityTitle": "screenshots have failed!",
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
  }]
  EOF
  fi
