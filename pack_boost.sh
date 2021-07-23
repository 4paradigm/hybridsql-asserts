#!/bin/bash

# the script will install boost and baidu-common together

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

source var.sh
OS=$(os_type)

DEPS_SOURCE="$PWD/src"
DEPS_PREFIX="$PWD/boost-$VERSION"

pushd "$DEPS_SOURCE"

tar -zxf boost_1_69_0.tar.gz
pushd boost_1_69_0
if [[ "${OS}" = "darwin" ]]; then
    ./bootstrap.sh compiler.blacklist clang -with-toolset=clang
else
    ./bootstrap.sh
fi
./b2 link=static cxxflags=-fPIC cflags=-fPIC release install --prefix="$DEPS_PREFIX"

popd

tar xzf common-1.0.0.tar.gz
pushd common-1.0.0
if [[ "${OS}" = "darwin" ]]; then
    # 'syscall' is deprecated: first deprecated in OS X 10.12
	sed -i '' 's/^#include <syscall.h>/#include <pthread.h>/' src/logging.cc
	sed -i '' 's/thread_id = syscall(__NR_gettid)/pthread_threadid_np(0, \&thread_id)/' src/logging.cc
fi
make -j"$(nproc)" INCLUDE_PATH="-Iinclude -I$DEPS_PREFIX/include" PREFIX="$DEPS_PREFIX" install

popd

popd

tar czf boost-$VERSION-bin.tar.gz "boost-$VERSION/"
