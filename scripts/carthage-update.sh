#!/bin/bash

carthage update $1 --platform iOS --no-use-binaries

#find ./Carthage/Build/iOS/ -name *.bcsymbolmap $(find ./Carthage/DerivedData/Build/Products/Release-iphoneos -name *.bcsymbolmap | sed 's#./Carthage/DerivedData/Build/Products/Release-iphoneos/#-not -name #') -exec rm {} \;
