#!/bin/bash

# merge llvm, boost, and other build artifcats into single archive
# pack_all.sh accept one extra argument indicate which directory those sub packages locate
# by default, sub packages consider exist in the same directory as pack_all.sh

set -eE
set -x

cd "$(dirname "$0")"

source var.sh

WORKDIR=${1:-.}
OS=$(os_type)
ARCH=$(target_arch)

ROOT=$(pwd)
INSTALL_DIR="thirdparty-$(date +%Y-%m-%d)-$OS-$ARCH"
SRC_DIR="thirdsrc-$(date +%Y-%m-%d)"

export OUT="$ROOT/$WORKDIR/$INSTALL_DIR"
unpack_and_install() {
    local name=$1
    find . -maxdepth 1 -type f -iname "$name*.tar.gz" -exec tar xzf {} -C "$OUT" --strip-components=1 \;
}

mkdir -p "$OUT"

pushd "$WORKDIR"

unpack_and_install boost
unpack_and_install llvm
unpack_and_install libother

# needs a soft link lib64->lib for Mac OS
tar czf "$INSTALL_DIR.tar.gz" "$INSTALL_DIR"

mkdir -p "$SRC_DIR"
tar xzf src/apache-zookeeper-*.tar.gz -C "$SRC_DIR"
tar czf "$SRC_DIR.tar.gz" "$SRC_DIR"

popd
