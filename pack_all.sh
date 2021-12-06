#!/bin/bash

# merge llvm, boost, and other build artifcats into single archive
# pack_all.sh accept one extra argument indicate which directory those sub packages locate
# by default, sub packages consider exist in the same directory as pack_all.sh

set -eE
set -x

cd "$(dirname "$0")"

source var.sh

INSTALL_PREFIX=${1:-deps}

OS=$(os_type)
ARCH=$(target_arch)
DISTRO=$(distro)
INSTALL_DIR="thirdparty-$(date +%Y-%m-%d)-$OS-$ARCH"
if [ -n "$DISTRO" ]; then
    INSTALL_DIR="$INSTALL_DIR-$DISTRO"
fi
# SRC_DIR="thirdsrc-$(date +%Y-%m-%d)"

pushd "$INSTALL_PREFIX"
    mv usr "$INSTALL_DIR"
    # needs a soft link lib64->lib for Mac OS
    tar czf "$INSTALL_DIR.tar.gz" "$INSTALL_DIR"

    # mv src "$SRC_DIR"
    # tar xzf src/apache-zookeeper-*.tar.gz -C "$SRC_DIR"
    # tar czf "$SRC_DIR.tar.gz" "$SRC_DIR"
popd
