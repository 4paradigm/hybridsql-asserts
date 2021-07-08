#!/bin/bash

set -eE
set -x

cd "$(dirname "$0")"

ROOT=$(pwd)
WORKDIR=${1:-artifact}
INSTALL_DIR="thirdparty-$(date +%Y-%m-%d)"
SRC_DIR="thirdsrc-$(date +%Y-%m-%d)"

TARDIR=${2:-$WORKDIR}
pushd $TARDIR
TARDIR=$(pwd)
echo "tars dir: $TARDIR"
popd


echo "OS Type: ${OS_TYPE}"
export OUT="$ROOT/$WORKDIR/$INSTALL_DIR"
unpack_and_install() {
    local name=$1
    find $TARDIR -maxdepth 1 -type f -iname "$name*${OS_TYPE}.tar.gz" -exec tar xzf {} \;
    pushd "$name*${OS_TYPE}"-*/

    # Mac install(1) doesn't support -D, so we create dirs first, then copy
    find . -type d -exec install -d {} "$OUT"/{} \;
    find . -type f -exec install {} "$OUT"/{} \;
    popd
}

mkdir -p $WORKDIR
pushd "$WORKDIR"

mkdir -p "$INSTALL_DIR"

unpack_and_install boost
if [[ "${OS_TYPE}" == "Mac" ]]; then
    echo "skip install llvm temperory"
else
    unpack_and_install llvm
fi
unpack_and_install libother

tar czf "$INSTALL_DIR-${OS_TYPE}.tar.gz" "$INSTALL_DIR"

mkdir -p "$SRC_DIR"
tar xzf $TARDIR/src/apache-zookeeper-*.tar.gz -C "$SRC_DIR"
tar czf "$SRC_DIR-${OS_TYPE}.tar.gz" "$SRC_DIR"

popd
