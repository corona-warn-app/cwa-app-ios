#!/usr/bin/env bash

## This script converts *.proto files to *.pb.swift files.
## In order to work properly protoc should be installed.



if ! hash protoc 2>/dev/null; then
    echo "[ERROR] Converting .proto-files to .swift-files requires protoc."
    echo "[ERROR] You can install protoc by executing the following command:"
    echo ""
    echo "$ brew install swift-protobuf"
    exit
fi
rm -rf ../src/xcode/ENA/ENA/backend/generated/* #Delete old files

for protoFile in $(find ./resources -name '*.proto');
	do 
		protoc --swift_out=../src/xcode/ENA/ENA/backend/generated/ --experimental_allow_proto3_optional --proto_path=./resources $protoFile
	done;

