#!/bin/bash

set -e

mkdir -p _build
cd _build

# hack a symlink for rpcgen
ln -s ${CPP} ${BUILD_PREFIX}/bin/cpp

# configure
cmake \
	${SRC_DIR} \
	${CMAKE_ARGS} \
	-DCMAKE_BUILD_TYPE:STRING=Release \
	-DCMAKE_CROSSCOMPILING_EMULATOR:STRING="${CMAKE_CROSSCOMPILING_EMULATOR}" \
	-DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
	-DENABLE_PYTHON2:BOOL=FALSE \
	-DENABLE_PYTHON3:BOOL=FALSE \
	-DGDS_INCLUDE_DIR="${PREFIX}/include/gds" \
;

# build
cmake --build . --parallel ${CPU_COUNT} --verbose

# test
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
	ctest --parallel ${CPU_COUNT} --verbose
fi

# install
cmake --build . --parallel ${CPU_COUNT} --verbose --target install
