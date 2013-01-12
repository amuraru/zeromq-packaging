#!/bin/bash
set -e

BUILD="1"
DIST="precise"

ZMQ_GIT_DIR="$1"
if [ -z "${ZMQ_GIT_DIR}" ]; then
    echo "The root of zeromq git dir is required"
    exit 1
fi
cd $ZMQ_GIT_DIR
BUILD_TS=${BUILD_TS:-"$(date +%Y%m%d-%H%M%S)"}
DEB_DIR="$HOME/debbuild/$BUILD_TS"
mkdir -p $DEB_DIR

pwd
git clean -xfd
./autogen.sh
./configure --prefix=/usr

SPEC_VERSION=$(grep 'Version:' jzmq.spec | cut -f2 -d':' | tr -d ' ')
VERSION=${VERSION:-$SPEC_VERSION}
NEXT_VERSION=$(($(echo $VERSION | cut -f1 -d.)+1))
export LDFLAGS="-Wl,--as-needed -Wl,-z,defs"

make

rm -rf doc-pak
mkdir doc-pak

(cat <<EOF
The Java ZeroMQ bindings
The 0MQ lightweight messaging kernel is a library which extends the standard
socket interfaces with features traditionally provided by specialised
messaging middleware products. 0MQ sockets provide an abstraction
of asynchronous message queues, multiple messaging patterns, message
filtering (subscriptions), seamless access to multiple transport
protocols and more.
This package contains the Java Bindings for ZeroMQ.

Check: https://github.com/zeromq/jzmq

Changelog:
EOF
git log --oneline --no-merges | head -n20) > description-pak

sudo checkinstall --install=no --fstrans -D --reset-uids --autodoinst --addso --stripso --strip --backup=no \
    --pkgname="jzmq" \
    --provides="jzmq" \
    --pkgversion="${VERSION}${ZMQ_VERSION}" \
    --pkgrelease="${BUILD}${DIST}" \
    --maintainer="amuraru@adobe.com" \
    --pkggroup="libs" \
    --pkgsource="http://github.com/zeromq/jzmq" \
    --spec="/dev/null" <<EOF
10
zeromq (>= $VERSION), zeromq (<< $NEXT_VERSION)
EOF

mv jzmq_${VERSION}${ZMQ_VERSION}-${BUILD}${DIST}*.deb $DEB_DIR/

echo "DEB package generated in $DEB_DIR dir"

