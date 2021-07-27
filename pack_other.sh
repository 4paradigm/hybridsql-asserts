#!/bin/bash

# Copyright 2021 4Paradigm
# Copyright 2021 aceforeverd <teapot@aceforverd.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# install_deps.sh: build & install dependencies.

set -eE

cd "$(dirname "$0")"

if [ -d '/opt/rh/devtoolset-8' ]; then
    # shellcheck disable=SC1091
    source /opt/rh/devtoolset-8/enable
fi

if [ -d '/opt/rh/rh-python38' ]; then
    # shellcheck disable=SC1091
    source /opt/rh/rh-python38/enable
fi

source var.sh
OS=$(os_type)
ARCH=$(target_arch)

VERSION=$(date +%Y-%m-%d)

DEPS_SOURCE="$PWD/src"
DEPS_PREFIX="$PWD/libother-$VERSION"
DEPS_CONFIG="--prefix=$DEPS_PREFIX --disable-shared --with-pic"

export CXXFLAGS=" -O3 -fPIC"
export CFLAGS=" -O3 -fPIC"

mkdir -p "$DEPS_PREFIX/lib" "$DEPS_PREFIX/include" "$DEPS_SOURCE"
export PATH=${DEPS_PREFIX}/bin:$PATH

pushd "$DEPS_SOURCE"/

if [ ! -f gtest_succ ]; then
    echo "installing gtest ...."
    tar xzf googletest-release-1.11.0.tar.gz

    pushd googletest-release-1.11.0
    cmake -H. -Bbuild -DCMAKE_INSTALL_PREFIX="$DEPS_PREFIX" -DCMAKE_CXX_FLAGS=-fPIC
    cmake --build build -- $MAKEOPTS
    cmake --build build --target install
    popd

    touch gtest_succ
    echo "install gtest done"
fi

if [ -f "glog_succ" ]; then
    echo "glog exist"
else
    echo "installing glog ..."
    tar xzf glog-0.4.0.tar.gz
    pushd glog-0.4.0
    ./autogen.sh && CXXFLAGS=-fPIC ./configure --prefix="$DEPS_PREFIX" --enable-shared=no
    make $MAKEOPTS install
    popd
    touch glog_succ
    echo "installed glog"
fi

if [ -f "gflags_succ" ]; then
    echo "gflags-2.2.0.tar.gz exist"
else
    tar zxf gflags-2.2.0.tar.gz
    pushd gflags-2.2.0
    # Mac will failed in create build/ cuz the dir contains a file named 'BUILD', so we use 'cmake_build' as the build dir.
    # gflags BUILD_SHARED_LIBS default is OFF. And if BUILD_SHARED_LIBS=OFF, BUILD_STATIC_LIBS will be ON.
    cmake -H. -Bcmake_build -DCMAKE_INSTALL_PREFIX="$DEPS_PREFIX" -DGFLAGS_NAMESPACE=google -DCMAKE_CXX_FLAGS=-fPIC
    cmake --build cmake_build -- $MAKEOPTS
    cmake --build cmake_build --target install
    popd

    touch gflags_succ
    echo "install gflags done"
fi

if [ -f "zlib_succ" ]; then
    echo "zlib exist"
else
    echo "installing zlib..."
    tar xzf zlib-1.2.11.tar.gz
    pushd zlib-1.2.11
    CFLAGS="-O3 -fPIC" ./configure --static --prefix="$DEPS_PREFIX"
    make $MAKEOPTS
    make install
    popd
    touch zlib_succ
    echo "install zlib done"
fi

if [ -f "protobuf_succ" ]; then
    echo "protobuf exist"
else
    echo "start install protobuf ..."
    tar zxf protobuf-3.6.1.3.tar.gz

    pushd protobuf-*/
    ./autogen.sh && ./configure --disable-shared --with-pic --prefix "${DEPS_PREFIX}" CPPFLAGS=-I"$DEPS_PREFIX/include" LDFLAGS=-L"$DEPS_PREFIX/lib"
    make $MAKEOPTS
    make install
    popd

    touch protobuf_succ
    echo "install protobuf done"
fi

if [ -f "snappy_succ" ]; then
    echo "snappy exist"
else
    echo "start install snappy ..."
    tar zxf snappy-1.1.1.tar.gz
    pushd snappy-1.1.1/
    ./configure $DEPS_CONFIG
    make $MAKEOPTS
    make install
    popd

    touch snappy_succ
    echo "install snappy done"
fi

if [[ -f "unwind_succ" ]]; then
    echo "unwind_exist"
elif [[ $OS = "darwin" ]]; then
    echo "For Mac, libunwind doesn't need to be built separately"
else
    if [[ $ARCH = 'aarch64' ]]; then
        tar zxf libunwind-1.5.0.tar.gz
        pushd libunwind-1.5.0/
    else
        tar xzf libunwind-1.1.tar.gz
        pushd libunwind-1.1/
        autoreconf -i
    fi
    ./configure --prefix="$DEPS_PREFIX" --enable-shared=no
    make $MAKEOPTS
    make install
    popd

    touch unwind_succ
fi

if [ -f "gperf_succ" ]; then
    echo "gperf_succ exist"
else
    tar zxf gperftools-2.5.tar.gz
    pushd gperftools-2.5/
    ./configure --enable-cpu-profiler --enable-heap-checker --enable-heap-profiler --prefix="$DEPS_PREFIX" --enable-shared=no
    make $MAKEOPTS
    make install
    popd
    touch gperf_succ
fi

if [ -f "leveldb_succ" ]; then
    echo "leveldb exist"
else
    # TODO fix compile on leveldb 1.23
    tar zxf leveldb-1.20.tar.gz
    pushd leveldb-1.20
    make $MAKEOPTS OPT="-O2 -DNDEBUG -fPIC"
    cp -rf include/* "$DEPS_PREFIX/include"
    cp out-static/libleveldb.a "$DEPS_PREFIX/lib"
    popd
    touch leveldb_succ
fi

if [ -f "openssl_succ" ]; then
    echo "openssl exist"
else
    unzip OpenSSL_1_1_0.zip
    pushd openssl-OpenSSL_1_1_0
    # On Mac OS, sed must use `-i extension` for saving backups with the specified extension.
    # But we can give a zero-length extension, no backup will be saved.
    sed -i'' -e 's#qw/glob#qw/:glob#' Configure
    sed -i'' -e 's#qw/glob#qw/:glob#' test/build.info
    if [[ $ARCH = aarch64 ]]; then
        ./config --prefix="$DEPS_PREFIX" --openssldir="$DEPS_PREFIX" no-afalgeng no-shared
    else
        ./config --prefix="$DEPS_PREFIX" --openssldir="$DEPS_PREFIX" no-shared
    fi
    make $MAKEOPTS
    make install
    rm -rf "$DEPS_PREFIX"/lib/libssl.so*
    rm -rf "$DEPS_PREFIX"/lib/libcrypto.so*
    popd
    touch openssl_succ
    echo "openssl done"
fi

if [[ $ARCH = 'aarch64' ]]; then
    unzip absl.zip
    pushd abseil-cpp-2e94e5b6e152df9fa9c2fe8c1b96e1393973d32c/
else
    tar xf absl.tar.gz
    pushd abseil-cpp-a50ae369a30f99f79d7559002aba3413dac1bd48/
fi
cmake -H. -Bbuild -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_PREFIX="$DEPS_PREFIX" -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_STANDARD=17 -DABSL_USE_GOOGLETEST_HEAD=OFF -DABSL_RUN_TESTS=OFF \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON
cmake --build build
cmake --build build --target install
popd

if [ -f "brpc_succ" ]; then
    echo "brpc exist"
else
    unzip incubator-brpc.zip
    pushd incubator-brpc-*/
    if [[ $ARCH = aarch64 ]]; then
        # those options not exist on arm
        sed -e '/CXXFLAGS+=-msse4 -msse4.2/s/^/#/' -i Makefile
    fi
    sh config_brpc.sh --with-glog --headers="$DEPS_PREFIX/include" --libs="$DEPS_PREFIX/lib"
    make $MAKEOPTS libbrpc.a output/include
    cp -rf output/include/* "$DEPS_PREFIX/include/"
    cp libbrpc.a "$DEPS_PREFIX/lib"
    popd

    touch brpc_succ
    echo "brpc done"
fi

if [ -f "bison_succ" ]; then
    echo "bison exist"
else
    tar zxf bison-3.4.tar.gz
    pushd bison-3.4
    ./configure --prefix="$DEPS_PREFIX" --enable-relocatable
    make install
    popd
    touch bison_succ
fi

if [ -f "benchmark_succ" ]; then
    echo "benchmark exist"
else
    tar zxf v1.5.0.tar.gz
    pushd benchmark-1.5.0
    mkdir -p build
    cd build
    cmake -DCMAKE_INSTALL_PREFIX="$DEPS_PREFIX" -DCMAKE_CXX_FLAGS=-fPIC -DBENCHMARK_ENABLE_GTEST_TESTS=OFF ..
    make $MAKEOPTS
    make install
    popd
    touch benchmark_succ
fi

if [ -f "swig_succ" ]; then
    echo "swig exist"
else
    tar -zxf swig-4.0.1.tar.gz
    pushd swig-4.0.1
    ./autogen.sh
    ./configure --without-pcre --prefix="$DEPS_PREFIX"
    make $MAKEOPTS
    make install
    popd
    touch swig_succ
fi

if [ -f "yaml_succ" ]; then
    echo "yaml-cpp installed"
else
    tar -zxf yaml-cpp-0.6.3.tar.gz
    pushd yaml-cpp-yaml-cpp-0.6.3
    mkdir -p build
    cd build
    cmake -DCMAKE_INSTALL_PREFIX="$DEPS_PREFIX" ..
    make $MAKEOPTS
    make install
    popd
    touch yaml_succ
fi

if [ -f "sqlite_succ" ]; then
    echo "sqlite installed"
else
    unzip sqlite-*.zip
    pushd sqlite-version-3.32.3
    mkdir -p build
    cd build
    ../configure --prefix="$DEPS_PREFIX" --disable-tcl --enable-shared=no
    make $MAKEOPTS && make install
    popd
    touch sqlite_succ
fi

if [ -f zookeeper_succ ]; then
    echo "zookeeper installed"
else
    tar -zxf apache-zookeeper-3.4.14.tar.gz
    pushd zookeeper-3.4.14/zookeeper-client/zookeeper-client-c/
    if [[ $OS = "darwin" ]]; then
        CC="clang" CFLAGS="$CFLAGS" ./configure --prefix="$DEPS_PREFIX" --enable-shared=no
    else
        autoreconf -if
        # see https://issues.apache.org/jira/browse/ZOOKEEPER-3293
        CFLAGS="$CFLAGS -Wno-error=format-overflow=" ./configure --prefix="$DEPS_PREFIX" --enable-shared=no
    fi

    make $MAKEOPTS
    make install
    popd
fi

popd

tar czf "libother-$VERSION.tar.gz" "libother-$VERSION"/
