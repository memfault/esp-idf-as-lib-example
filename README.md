# Memfault ESP-IDF "As-Lib" Example Project

This project shows how to integrate the Memfault SDK into an ESP-IDF project
that's using a custom CMake build setup, as described in this document:

https://docs.espressif.com/projects/esp-idf/en/v5.1.1/esp32/api-guides/build-system.html#using-esp-idf-in-custom-cmake-projects

The example is based on the `examples/build_system/cmake/idf_as_lib` example:

https://github.com/espressif/esp-idf/tree/v5.1.1/examples/build_system/cmake/idf_as_lib


## Building this Example

First setup and activate ESP-IDF environment (this example is only tested with
v5.1.1).

Then run the following commands to build the example:

```bash
# see the justfile for the commands this runs.
# if you have the just program installed, you don't need to use the ./just.sh
# wrapper.

# build the project
./just.sh build esp32s3

# flash and start the serial monitor
./just.sh run esp32s3
```

This should drop you into a serial console on the esp32 board:

```bash
▙▗▌       ▗▀▖      ▜▐     ▄▄▀▀▄▄
▌▘▌▞▀▖▛▚▀▖▐  ▝▀▖▌ ▌▐▜▀   █▄    ▄█
▌ ▌▛▀ ▌▐ ▌▜▀ ▞▀▌▌ ▌▐▐ ▖  ▄▀▀▄▄▀▀▄
▘ ▘▝▀▘▘▝ ▘▐  ▝▀▘▝▀▘ ▘▀    ▀▀▄▄▀▀


Type 'help' to get the list of commands.
Use UP/DOWN arrows to navigate through command history.
Press TAB when typing command name to auto-complete.
I (507) main_task: Returned from app_main()
esp32>  help
```

You can test crashes + exporting data (`export` command for base64 chunks).
