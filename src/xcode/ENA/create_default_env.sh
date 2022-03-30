#!/usr/bin/env bash

set -euo pipefail

pushd `dirname '${0}'`

LOCAL_ENVIRONMENTS=./ENA/Resources/Environment/Environments.json

# if not present create a new Environment file from default
if [ ! -f ${LOCAL_ENVIRONMENTS} ]; then
    cp ./ENA/Resources/Environment/Environments.default.json ${LOCAL_ENVIRONMENTS}
fi

popd
