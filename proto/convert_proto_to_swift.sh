#!/usr/bin/env bash

## This script converts *.proto files to *.pb.swift files.
## In order to work properly protoc should be installed.

set -euo pipefail
IFS=$'\n\t'

if ! hash protoc 2>/dev/null; then
    echo "[ERROR] Converting .proto-files to .swift-files requires protoc."
    echo "[ERROR] You can install protoc by executing the following command:"
    echo ""
    echo "$ brew install swift-protobuf"
    exit
fi

protoc  --swift_out=./output ./security.proto ./exposure_keys.proto ./DeveloperDiagnosisKeyFileProtobuf.proto
