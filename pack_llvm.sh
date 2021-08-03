#!/bin/bash

set -e

cd "$(dirname "$0")"

source var.sh

VERSION=9.0.0

if [ -d '/opt/rh/devtoolset-8' ]; then
    # shellcheck disable=SC1091
    source /opt/rh/devtoolset-8/enable
fi

if [ -d '/opt/rh/rh-python38' ]; then
    # shellcheck disable=SC1091
    source /opt/rh/rh-python38/enable
fi

DEPS_SOURCE="$PWD/src"
DEPS_PREFIX="$PWD/llvm-$VERSION"

ARCH=$(target_arch)

if [[ $ARCH = 'aarch64' ]]; then
    LLVM_TARGETS="AArch64"
elif [[ $ARCH = 'x86'* || $ARCH = 'i386' ]]; then
    LLVM_TARGETS="X86"
else
    LLVM_TARGETS=all
fi

echo "LLVM_TARGETS: $LLVM_TARGETS"

pushd "$DEPS_SOURCE"/

tar xf llvm-$VERSION.src.tar.xz
pushd llvm-$VERSION.src/
mkdir -p build && cd build

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$DEPS_PREFIX" -DLLVM_TARGETS_TO_BUILD="$LLVM_TARGETS" -DCMAKE_CXX_FLAGS=-fPIC ..
make $MAKEOPTS
make install
popd

popd

tar czf llvm-$VERSION-bin.tar.gz "llvm-$VERSION/"
