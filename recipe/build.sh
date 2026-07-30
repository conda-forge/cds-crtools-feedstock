#!/bin/bash


set -e
set -x

if [[ ${target_platform} == ${build_platform} ]]
then
export LIBCLANG_PATH=${BUILD_PREFIX}/lib
else
export PKG_CONFIG_ALLOW_CROSS=1
export LIBCLANG_PATH=${BUILD_PREFIX}/lib
fi

export C_INCLUDE_PATH=${PREFIX}/include:${BUILD_PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include:${BUILD_PREFIX}/include


mkdir -p _build
cd _build

# hack a symlink for rpcgen
ln -s ${CPP} ${BUILD_PREFIX}/bin/cpp

export LIBRARY_PATH=${LIBRARY_PATH}:${PREFIX}/lib

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export BINDGEN_EXTRA_CLANG_ARGS="-isystem $(clang -print-resource-dir)/include ${BINDGEN_EXTRA_CLANG_ARGS:-}"
clang -print-resource-dir
ls "$(clang -print-resource-dir)/include/stddef.h"

# configure
cmake \
	${SRC_DIR} \
	${CMAKE_ARGS} \
	-DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
	-DENABLE_PYTHON2:BOOL=FALSE \
	-DENABLE_PYTHON3:BOOL=FALSE \
	-DGDS_INCLUDE_DIR="${PREFIX}/include/gds" \
;

# build
cmake --build . --parallel ${CPU_COUNT} --verbose

# test
if [[ $build_platform == $target_platform || $target_platform == linux-* ]]; then
	ctest --parallel ${CPU_COUNT} --verbose
fi

# install
cmake --build . --parallel ${CPU_COUNT} --verbose --target install
