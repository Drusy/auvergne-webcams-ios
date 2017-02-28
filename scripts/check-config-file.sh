#!/bin/bash

set -e

function checkKey {
    echo ""
    echo "Checking images of type '$1'" ...
    IMAGES=$(grep "$1" "$CONFIGURATION_FILE" | tr -s " " | cut -d '"' -f 4)

    for image in $IMAGES; do
        echo "Checking '$image'..."
        curl --fail "$image" -o '/tmp/image'
    done
}

if [ -z "$1" ]; then
    echo "Please specify the configuration (JSON) file"
    exit -1
fi

CONFIGURATION_FILE="$1"

if [ ! -f "$CONFIGURATION_FILE" ]; then
    echo "Cannot find $CONFIGURATION_FILE"
    exit -1
fi

checkKey "imageLD"
checkKey "imageHD"
