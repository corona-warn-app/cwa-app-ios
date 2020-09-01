#!/usr/bin/env bash

set -euo pipefail

pushd `dirname ${0}`

LOCAL_SETTINGS=./ENA/LocalSettings.swift

# if not present create a new LocalSettings file from defaults
if [ ! -f ${LOCAL_SETTINGS} ]; then
    cp ./ENA/LocalSettings.default.swift ${LOCAL_SETTINGS}
fi

popd
