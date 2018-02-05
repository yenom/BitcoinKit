#!/bin/sh
set -ex

CURRENTPATH=$(pwd)

PLATFORM=`xcrun -sdk iphoneos --show-sdk-platform-path`
SDK=`xcrun -sdk iphoneos --show-sdk-path`

export CROSS_TOP=$PLATFORM/Developer
export CROSS_SDK=`basename $SDK`
export BUILD_TOOLS=`xcode-select --print-path`
export CC="`xcrun -find gcc` -arch armv7 -isysroot `xcrun -sdk iphoneos --show-sdk-path`"

TARGETDIR="$CURRENTPATH"/.build/iphoneos/armv7
mkdir -p "$TARGETDIR"

./Configure iphoneos-cross no-shared no-dso no-hw no-engine no-ssl2 no-ssl3 no-comp no-idea no-asm no-dtls no-dtls1 no-threads no-err no-npn no-psk no-srp no-ec2m no-weak-ssl-ciphers -fembed-bitcode -miphoneos-version-min=8.0 --openssldir="$TARGETDIR"

make clean
make
make install_sw
