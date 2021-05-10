#!/bin/bash

set -eE
set -x

cd "$(dirname "$0")"

ROOT=$(pwd)
WORKDIR=${1:-artifact}
INSTALL_DIR="thirdparty-$(date +%Y-%m-%d)"

export OUT="$ROOT/$WORKDIR/$INSTALL_DIR"
unpack_and_install() {
    local name=$1
    find . -maxdepth 1 -type f -iname "$name*.tar.gz" -exec tar xzf {} \;
    pushd "$name"-*/
    find . -type f -exec install -D {} "$OUT"/{} \;
    popd
}

pushd "$WORKDIR"

mkdir -p "$INSTALL_DIR"

unpack_and_install boost
unpack_and_install llvm
unpack_and_install libzetasql
unpack_and_install libother

tar czf "thirdparty-$(date +%Y-%m-%d).tar.gz" "$INSTALL_DIR"

popd
