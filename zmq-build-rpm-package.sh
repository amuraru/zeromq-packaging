#!/bin/bash
set -e

ZMQ_GIT_DIR="$1"
if [ -z "${ZMQ_GIT_DIR}" ]; then
    echo "The root of zeromq git dir is required"
    exit 1
fi
cd $ZMQ_GIT_DIR

BUILD_TS=${2:-"$(date +%Y%m%d-%H%M%S)"}
RPM_DIR="$HOME/rpmbuild/$BUILD_TS"
mkdir -p $RPM_DIR

pwd
git clean -xfd
./autogen.sh
./configure
VERSION=`sh version.sh`

(cat <<EOF
This package contains the ZeroMQ shared library
Version: $VERSION

Check: https://github.com/zeromq

Changelog:
EOF
git log --oneline --no-merges | head -n20) > ChangeLog

rm -rf /tmp/zeromq-$VERSION
mkdir /tmp/zeromq-$VERSION
cp -r * /tmp/zeromq-$VERSION/

tar -C /tmp/ -czvf $ZMQ_GIT_DIR/zeromq-${VERSION}.tar.gz zeromq-$VERSION
rpmbuild -tb --clean --define "_rpmdir $RPM_DIR" $ZMQ_GIT_DIR/zeromq-${VERSION}.tar.gz
