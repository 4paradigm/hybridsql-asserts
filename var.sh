#!/bin/bash

os_type() {
    if [[ "$OSTYPE" = "darwin"* ]]; then
        echo "darwin"
    else
        echo "$OSTYPE"
    fi
}
