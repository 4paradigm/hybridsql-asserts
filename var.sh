#!/bin/bash

os_type() {
    # use the OS environment variable, then bash env OSTYPE
    if [[ -n "$OS" ]]; then
        echo "$OS"
    elif [[ "$OSTYPE" = "darwin"* ]]; then
        echo "darwin"
    else
        echo "$OSTYPE"
    fi
}

target_arch() {
    # if ARCH environment variable is not provided, use the host architecture
    echo "${ARCH:-$(arch)}"
}
