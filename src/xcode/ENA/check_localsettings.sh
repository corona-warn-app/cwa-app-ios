#!/usr/bin/env bash

set -euo pipefail

pushd `dirname ${0}`

LOCAL_SETTINGS=./ENA/Resources/ServerEnvironment/ServerEnvironments.json

# if not present create a new LocalSettings file from defaults
if [ ! -f ${LOCAL_SETTINGS} ]; then
    cp ./ENA/Resources/ServerEnvironment/ServerEnvironments.default.json ${LOCAL_SETTINGS}
fi

popd
