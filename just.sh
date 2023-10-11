#!/usr/bin/env bash

set -e

# If just is not on PATH, and the 'just' file doesn't exist, download it first
# curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ${PWD}
if ! command -v just &>/dev/null; then
    if [ ! -f just ]; then
        echo "just not found, downloading..."
        curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to "${PWD}"
    fi
    # now add it to PATH for this script
    export PATH="${PWD}:${PATH}"
fi

# Now forward all args to ./just
just "$@"
