#!/bin/sh
set -ex

SCRIPT_DIR="$PWD/`dirname $0`"
OPENSSL_VERSION=1.0.2n

TDIR=`mktemp -d`
trap "{ cd - ; rm -rf $TDIR; exit 255; }" SIGINT

cd $TDIR

curl -O https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz
tar zxf openssl-$OPENSSL_VERSION.tar.gz

cd openssl-$OPENSSL_VERSION

sh "$SCRIPT_DIR/build_crypto_iphoneos_arm64.sh"
sh "$SCRIPT_DIR/build_crypto_iphoneos_armv7s.sh"
sh "$SCRIPT_DIR/build_crypto_iphoneos_armv7.sh"
sh "$SCRIPT_DIR/build_crypto_iphonesimulator_x86_64.sh"
sh "$SCRIPT_DIR/build_crypto_iphonesimulator_i386.sh"

xcrun lipo -create .build/iphonesimulator/i386/lib/libcrypto.a .build/iphonesimulator/x86_64/lib/libcrypto.a .build/iphoneos/armv7/lib/libcrypto.a .build/iphoneos/armv7s/lib/libcrypto.a .build/iphoneos/arm64/lib/libcrypto.a -o "$SCRIPT_DIR/../Libraries/crypto/libcrypto.a"
cp -rf $TDIR/openssl-$OPENSSL_VERSION/include $SCRIPT_DIR/../Libraries/crypto/

cd -
rm -rf $TDIR
