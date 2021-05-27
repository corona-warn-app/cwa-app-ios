#!/usr/bin/env bash

set -euo pipefail

while [ ! -f "${1}" ]
do
  sleep 1
done

echo "Fast Fail! ☠️"

# End current step and move on in job
# via: https://support.circleci.com/hc/en-us/articles/360015562253-Conditionally-end-a-running-job-gracefully
circleci-agent step halt

killall "iOS Simulator"
