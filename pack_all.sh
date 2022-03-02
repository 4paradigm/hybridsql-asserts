#!/bin/bash

# merge llvm, boost, and other build artifcats into single archive
# pack_all.sh accept one extra argument indicate which directory those sub packages locate
# by default, sub packages consider exist in the same directory as pack_all.sh

set -eE
set -x

cd "$(dirname "$0")"

source var.sh

INSTALL_PREFIX=deps
VERSION=

function usage ()
{
    echo "Usage :  $0 [options] [--]

    Options:
    -h       Display this message
    -i       Install prefix, default: deps
    -n       version number, if not given, default to short git sha"

}    # ----------  end of function usage  ----------

while getopts ":hvi:n:" opt
do
  case $opt in

    h)  usage; exit 0   ;;

    i)  INSTALL_PREFIX=$OPTARG ;;

    n)  VERSION=$OPTARG ;;

    * )  echo -e "\n  Option does not exist : $OPTARG\n"
          usage; exit 1   ;;

  esac    # --- end of case ---
done
shift $((OPTIND-1))

if [[ -z $VERSION ]]; then
    VERSION=$(git rev-parse --short HEAD)
fi

OS=$(os_type)
ARCH=$(target_arch)
DISTRO=$(distro)

if [[ $OS = 'darwin' ]] ; then
    INSTALL_DIR="thirdparty-$VERSION-$OS-$ARCH"
else
    INSTALL_DIR="thirdparty-$VERSION-$OS-$ARCH-$DISTRO"
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
