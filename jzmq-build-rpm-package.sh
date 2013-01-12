#!/bin/bash
set -e

JZMQ_GIT_DIR="$1"
if [ -z "${JZMQ_GIT_DIR}" ]; then
    echo "The root of jzmq git dir is required"
    exit 1
fi
cd $JZMQ_GIT_DIR

ZMQ_VERSION="${ZMQ_VERSION:-"X"}"

BUILD_TS=${BUILD_TS:-"$(date +%Y%m%d-%H%M%S)"}

RPM_DIR="$HOME/rpmbuild/$BUILD_TS"
mkdir -p $RPM_DIR

git clean -xfd
./autogen.sh
./configure
VERSION="$(grep 'Version:' jzmq.spec | cut -f2 -d':' | tr -d ' ')${ZMQ_VERSION}"
#SPEC_VERSION=$(grep 'Version:' jzmq.spec | cut -f2 -d':' | tr -d ' ')
#VERSION=${VERSION:-$SPEC_VERSION}

(cat <<EOF
This package contains the ZeroMQ shared library.

Check: https://github.com/zeromq/zeromq2-x

Changelog:
EOF
git log --oneline --no-merges | head -n20) > ChangeLog

rm -rf /tmp/jzmq-$VERSION
mkdir /tmp/jzmq-$VERSION
cp -r * /tmp/jzmq-$VERSION/

sed  "s#Version:       .*#Version:       $VERSION#g" jzmq.spec > /tmp/jzmq-$VERSION/jzmq.spec

tar -C /tmp -czvf $JZMQ_GIT_DIR/jzmq-${VERSION}.tar.gz jzmq-$VERSION
rpmbuild -tb --clean --define "_rpmdir $RPM_DIR" --define "version ${VERSION}" $JZMQ_GIT_DIR/jzmq-${VERSION}.tar.gz
