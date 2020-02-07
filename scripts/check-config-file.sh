#!/bin/bash

set -e

function downloadURL {
    URL="$1"

    echo "Checking '$URL'..."
    curl --fail "$URL" -o '/tmp/image'
}

function checkViewsurf {
    echo ""
    echo "Checking images of type '$1'" ...
    IMAGES=$(grep "$1" "$CONFIGURATION_FILE" | tr -s " " | cut -d '"' -f 4)

    for IMAGE in $IMAGES; do
        LAST=$(curl --fail -s -o - "$IMAGE/last")
        downloadURL "$IMAGE/${LAST}_tn.jpg"
        downloadURL "$IMAGE/$LAST.mp4"
    done
}

function checkImage {
    echo ""
    echo "Checking images of type '$1'" ...
    IMAGES=$(grep "$1" "$CONFIGURATION_FILE" | tr -s " " | cut -d '"' -f 4)

    for IMAGE in $IMAGES; do
        downloadURL "$IMAGE"
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

checkImage "imageLD"
checkImage "imageHD"

checkViewsurf "viewsurf"
