#!/bin/bash

# Builds zlib from source ready for LTO

set -e
ROOT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." > /dev/null && pwd )
GCC_ROOT=$1

if [[ $# -ne 1 ]]; then
    echo "Usage: build-lto-zlib.sh <path to gcc root>"
    exit 1
fi

ZLIB_VERSION=1.2.8

mkdir -p ${ROOT_DIR}/build
cd ${ROOT_DIR}/build
curl -s -L "https://github.com/madler/zlib/archive/v${ZLIB_VERSION}.tar.gz" | tar zxf -
cd zlib-${ZLIB_VERSION}

export LIBRARY_PATH=/usr/lib/$(gcc -print-multiarch)
export C_INCLUDE_PATH=/usr/include/$(gcc -print-multiarch)
export CPLUS_INCLUDE_PATH=/usr/include/$(gcc -print-multiarch)
export CXX=${GCC_ROOT}/bin/g++
export CC=${GCC_ROOT}/bin/gcc
export AR=${GCC_ROOT}/bin/gcc-ar
export RANLIB=${GCC_ROOT}/bin/gcc-ranlib
export CFLAGS="-O3 -flto -fuse-linker-plugin -fuse-ld=gold -march=native"
export LDFLAGS="-O3 -flto -fuse-linker-plugin -fuse-ld=gold -march=native"
./configure --static --prefix ${ROOT_DIR}/build/zlib --64
make -j4
make test
make install
