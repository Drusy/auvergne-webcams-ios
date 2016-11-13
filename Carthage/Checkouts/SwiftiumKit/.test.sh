#!/bin/sh

xcodebuild test -scheme SwiftiumKit -destination OS=latest,name="iPad Air" | xcpretty

exit $?
