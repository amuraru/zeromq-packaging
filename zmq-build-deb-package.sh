#!/bin/bash
set -e

BUILD="1precise"

ZMQ_GIT_DIR="$1"
if [ -z "${ZMQ_GIT_DIR}" ]; then
    echo "The root of zeromq git dir is required"
    exit 1
fi
cd $ZMQ_GIT_DIR

BUILD_TS=${2:-"$(date +%Y%m%d-%H%M%S)"}
DEB_DIR="$HOME/debbuild/$BUILD_TS"
mkdir -p $DEB_DIR

pwd
git clean -xfd
./autogen.sh
./configure --prefix=/usr --with-pgm --with-pic --with-gnu-ld --disable-static
make -j4
VERSION=`sh version.sh`

rm -rf doc-pak
mkdir doc-pak

(cat <<EOF
0mq library version ${VERSION}

The 0MQ lightweight messaging kernel is a library which extends the
standard socket interfaces with features traditionally provided by
specialised messaging middleware products. 0MQ sockets provide an
abstraction of asynchronous message queues, multiple messaging
patterns, message filtering (subscriptions), seamless access to
multiple transport protocols and more.
This package contains the ZeroMQ shared library.

Visit http://zero.mq for more details

Changelog:
EOF
git log --oneline --no-merges | head -n20) > description-pak

sudo checkinstall --install=no --fstrans -D --reset-uids --autodoinst --addso --stripso --strip --backup=no \
    --pkgname="zeromq" \
    --provides="zeromq" \
    --pkgversion="$VERSION" \
    --pkgrelease="$BUILD" \
    --replaces="libzmq-dev" \
    --maintainer="amuraru@adobe.com" \
    --pkggroup="libs" \
    --pkgsource="http://github.com/zeromq/" <<EOF
10
libc6 (>= 2.15), libgcc1 (>= 1:4.1.1), libstdc++6 (>= 4.2.1), libuuid1 (>= 2.16)
EOF

mv zeromq_$VERSION-$BUILD*.deb $DEB_DIR

echo "DEB package generated in $DEB_DIR dir"

