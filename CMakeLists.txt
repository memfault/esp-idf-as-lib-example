cmake_minimum_required(VERSION 3.16)
cmake_policy(SET CMP0011 NEW)

project(idf_as_lib C)

set(targets "esp32" "esp32s2" "esp32s3" "esp32c3" "esp32c2" "esp32c6" "esp32h2")

if(NOT "${TARGET}" IN_LIST targets)
message(FATAL_ERROR "Unknown target ${TARGET}")
endif()

# Include for ESP-IDF build system functions
include($ENV{IDF_PATH}/tools/cmake/idf.cmake)

get_filename_component(memfault_firmare_sdk_dir ${CMAKE_CURRENT_LIST_DIR}/memfault-firmware-sdk ABSOLUTE)

# Instead of using the "main" component as in an idf.py component-style
# project, inject one additional component dependency for the "memfault"
# component, which is normally inserted from the "common" set of components
set(MEMFAULT_PLATFORM_PORT_COMPONENTS "esp_https_ota")
# Insert the memfault config file directory
set(MEMFAULT_PLATFORM_EXTRA_INCLUDES ${CMAKE_CURRENT_LIST_DIR})
include(${memfault_firmare_sdk_dir}/ports/esp_idf/memfault.cmake)
idf_build_component(${memfault_firmare_sdk_dir}/ports/esp_idf/memfault)

# Create idf::{target} and idf::freertos static libraries
idf_build_process("${TARGET}"
                # try and trim the build; additional components
                # will be included as needed based on dependency tree
                #
                # although esptool_py does not generate static library,
                # processing the component is needed for flashing related
                # targets and file generation
                COMPONENTS
                    freertos
                    esptool_py
                    memfault
                SDKCONFIG ${CMAKE_CURRENT_LIST_DIR}/sdkconfig
                SDKCONFIG_DEFAULTS ${CMAKE_CURRENT_LIST_DIR}/sdkconfig.defaults
                BUILD_DIR ${CMAKE_BINARY_DIR})

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(elf_file ${CMAKE_PROJECT_NAME}.elf)
add_executable(${elf_file} main.c)

# Link the static libraries to the executable
target_link_libraries(${elf_file} idf::freertos idf::spi_flash)
# Attach additional targets to the executable file for flashing,
# linker script generation, partition_table generation, etc.
idf_build_executable(${elf_file})

# Setup custom target to always add build ID
set(elffile ${CMAKE_BINARY_DIR}/idf_as_lib.elf)
add_custom_target(
    memfault_build_id
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/__memfault_build_id
)
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/__memfault_build_id
    DEPENDS ${elffile}
    COMMAND python ${memfault_firmare_sdk_dir}/scripts/fw_build_id.py ${elffile}
)

# Add custom target/command to remove compact log section due to
# esptool.py incorrectly flashing non-loadable sections
add_custom_target(
    memfault_remove_log_fmt_section
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/__memfault_remove_log_fmt_section
)
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/__memfault_remove_log_fmt_section
    DEPENDS memfault_build_id
    BYPRODUCTS ${elffile}.memfault_log_fmt
    COMMAND ${CMAKE_COMMAND} -E copy ${elffile} ${elffile}.memfault_log_fmt
    COMMAND ${CMAKE_OBJCOPY} --remove-section log_fmt ${elffile}
)

# Add memfault_remove_log_fmt_section as depedency before binary generation
# memfault_build_id -> memfault_remove_log_fmt_section ->
# gen_project_binary -> app -> .bin files
# NB this requires ESP-IDF 4.0+
add_dependencies(gen_project_binary memfault_remove_log_fmt_section)

# Alternate variant that supports <4.0
# # Add the Memfault Build ID so each build can have a unique version.
# set(IDF_PROJECT_EXECUTABLE ${PROJECT_NAME}.elf)
# add_custom_command(TARGET ${IDF_PROJECT_EXECUTABLE}
# POST_BUILD
# # Compute and insert the build id
# COMMAND python ${memfault_firmare_sdk_dir}/scripts/fw_build_id.py ${IDF_PROJECT_EXECUTABLE}
# # Save a copy of the ELF that includes the 'log_fmt' section
# BYPRODUCTS ${IDF_PROJECT_EXECUTABLE}.memfault_log_fmt
# COMMAND ${CMAKE_COMMAND} -E copy ${IDF_PROJECT_EXECUTABLE} ${IDF_PROJECT_EXECUTABLE}.memfault_log_fmt
# COMMAND ${CMAKE_COMMAND} -E echo "*** NOTE: the symbol file to upload to app.memfault.com is ${IDF_PROJECT_EXECUTABLE}.memfault_log_fmt ***"
# # Remove the 'log_fmt' compact log section, which confuses elf2image
# COMMAND ${CMAKE_OBJCOPY} --remove-section log_fmt ${IDF_PROJECT_EXECUTABLE}
# )
