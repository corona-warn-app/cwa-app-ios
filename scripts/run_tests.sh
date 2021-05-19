#!/bin/bash

set -o pipefail

CORE_COUNT=`sysctl -n hw.ncpu`
RESULT_PATH="fastlane/test_output/ENA.xcresult"

EXIT_STATUS=0
defer() {
  # zip results in very case
  zip -r -q fastlane/test_output/ENA.xcresult.zip fastlane/test_output/ENA.xcresult
  exit ${EXIT_STATUS}
}
trap defer EXIT

cd src/xcode

# local cleanup
if [ -e ${RESULT_PATH} ]; then
  rm -rf ${RESULT_PATH}
fi

## test
xcodebuild \
  -workspace "ENA.xcworkspace" \
  -scheme ENA \
  -destination "platform=iOS Simulator,OS=14.5,name=iPhone 11" \
  -testPlan AllTests \
  -only-test-configuration "DE" \
  -derivedDataPath "./DerivedData" \
  -enableCodeCoverage YES \
  -resultBundlePath "fastlane/test_output/ENA.xcresult" \
  -parallel-testing-enabled YES \
  -parallel-testing-worker-count "${CORE_COUNT}" \
  -maximum-concurrent-test-simulator-destinations "${CORE_COUNT}" \
  test-without-building

EXIT_STATUS=$?
