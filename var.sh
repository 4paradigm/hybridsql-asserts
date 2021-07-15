#!/bin/bash

function os_type() {
    if [[ "${OSTYPE}" == "darwin"* ]]; then
	    echo "Mac"
    else
	    echo "Linux"
    fi
}
