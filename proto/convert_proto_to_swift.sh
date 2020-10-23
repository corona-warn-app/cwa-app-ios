#!/usr/bin/env bash

## This script converts *.proto files to *.pb.swift files.
## In order to work properly protoc should be installed.

set -euo pipefail

if ! hash protoc 2>/dev/null; then
    echo "[ERROR] Converting .proto-files to .swift-files requires protoc."
    echo "[ERROR] You can install protoc by executing the following command:"
    echo ""
    echo "$ brew install swift-protobuf"
    exit
fi
mkdir -p ../src/xcode/gen/output #Create output if it doesnt exist
rm -rf ../src/xcode/gen/output/* #Delte old files

for protoFile in $(find ./resources -name '*.proto');
	do 
		protoc --swift_out=../src/xcode/gen/output --experimental_allow_proto3_optional --proto_path=./resources $protoFile
	done;

