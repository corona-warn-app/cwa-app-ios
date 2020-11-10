#!/usr/bin/env zsh
set -euo pipefail

if [[ -f $1 ]]; then
    # create a backup of the original json file
    mv $1 swiftlint.result.original.json

    # try to transform object into array
    {
        cat swiftlint.result.original.json | jq '.["issues"]' > $1
    } || {
        # if that fails, restore the original
        echo "Restoring original input $1"
        mv swiftlint.result.original.json $1
    }
else
    echo "Lintfile $1 not found. Check if linting was performed and paths are up to date"
    exit 1
fi
