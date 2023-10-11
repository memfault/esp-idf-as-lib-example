#!/usr/bin/env bash

set -e

# error if any referenced variable is unset
set -u

# need to cd to build, the flash_project_args contain relative paths
cd build
python $IDF_PATH/components/esptool_py/esptool/esptool.py write_flash @flash_project_args
python -m esp_idf_monitor idf_as_lib.elf
