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
     ./*.proto
