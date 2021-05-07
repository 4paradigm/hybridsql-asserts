#!/bin/bash

set -e

cd "$(dirname "$0")"

VERSION=1.69.0

if [ -d '/opt/rh/devtoolset-8' ] ; then
    # shellcheck disable=SC1091
    source /opt/rh/devtoolset-8/enable
fi

if [ -d '/opt/rh/rh-python38' ] ; then
    # shellcheck disable=SC1091
    source /opt/rh/rh-python38/enable
fi

DEPS_SOURCE="$PWD/src"
DEPS_PREFIX="$PWD/boost-$VERSION"

pushd "$DEPS_SOURCE"
tar -zxf boost_1_69_0.tar.gz

pushd boost_1_69_0

./bootstrap.sh
./b2 link=static cxxflags=-fPIC cflags=-fPIC release install --prefix="$DEPS_PREFIX"

popd

popd

tar czf boost-$VERSION-bin.tar.gz "$DEPS_PREFIX"
