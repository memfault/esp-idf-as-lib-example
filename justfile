default: (build "esp32")

build TARGET:
    cmake -B build -DCMAKE_TOOLCHAIN_FILE="${IDF_PATH}/tools/cmake/toolchain-{{TARGET}}.cmake" -DTARGET={{TARGET}} -GNinja
    cmake --build build

run TARGET: (build TARGET)
    cd build && \
      python $IDF_PATH/components/esptool_py/esptool/esptool.py write_flash @flash_project_args && \
      python -m esp_idf_monitor idf_as_lib.elf
