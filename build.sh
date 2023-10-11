#!/usr/bin/env bash

set -euo pipefail

cmake -B build -DCMAKE_TOOLCHAIN_FILE="${IDF_PATH}/tools/cmake/toolchain-${TARGET}.cmake" -DTARGET=${TARGET} -GNinja
cmake --build build
