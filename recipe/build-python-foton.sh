#!/bin/bash

set -e

# build out-of-tree
_builddir="_build_foton_${PY_VER}"
mkdir -pv ${_builddir}
pushd ${_builddir}

# build this directory
BUILD_DIR="src/python/foton"

# configure
cmake \
	${SRC_DIR} \
	-DONLY_FOTON=1 \
	-DCMAKE_BUILD_TYPE:STRING=Release \
	-DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
	-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
	-DENABLE_PYTHON${PY_VER%%.*}:BOOL=yes \
	-DGDS_INCLUDE_DIR=${PREFIX}/include/gds \
	-DPython3_EXECUTABLE:FILE="${PYTHON}" \
;

# build
cmake --build "${BUILD_DIR}" --parallel ${CPU_COUNT} --verbose

# test
# if [[ $build_platform == $target_platform || $target_platform == linux-* ]]; then
# 	ctest --test-dir "${BUILD_DIR}" --parallel ${CPU_COUNT} --verbose
# fi

# install
cmake --build "${BUILD_DIR}" --parallel ${CPU_COUNT} --verbose --target install
