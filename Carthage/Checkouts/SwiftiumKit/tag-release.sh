#!/bin/sh

VERSION=$(/usr/libexec/PlistBuddy SwiftiumKit/Info.plist -c "print CFBundleShortVersionString")

TAG=v$VERSION

echo "Have you updated the changelog for version $VERSION ? (ctrl-c to go update it)"
read

set -e

carthage build --no-skip-current && carthage archive SwiftiumKit

echo "Creating tag $TAG and pushing it to github"
git tag $TAG
git push --tags

echo "You can now upload SwiftiumKit.framework.zip and edit release notes from https://github.com/openium/SwiftiumKit/releases/edit/$TAG"

