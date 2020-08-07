#!/usr/bin/env bash

## This script converts *.proto files to *.pb.swift files.
## In order to work properly protoc should be installed.
cd resources

set -euo pipefail
IFS=$'\n\t'

if ! hash protoc 2>/dev/null; then
    echo "[ERROR] Converting .proto-files to .swift-files requires protoc."
    echo "[ERROR] You can install protoc by executing the following command:"
    echo ""
    echo "$ brew install swift-protobuf"
    exit
fi
mkdir -p ../../src/xcode/gen/output
protoc \
     --experimental_allow_proto3_optional \
     --swift_out=../../src/xcode/gen/output \
     ./app_config.proto \
     ./app_config_attenuation_duration.proto \
     ./app_config_app_version_config.proto \
     ./submission_payload.proto \
     ./apple_export.proto \
     ./temporary_exposure_key_export.proto \
     ./temporary_exposure_key_signature_list.proto
