#!/bin/bash

set -eE

RED='\033[0;31m'
NC='\033[0m'

analyze_so() {
    local so_file
    so_file=$1
    local archive_file
    archive_file=$(echo "$so_file" | sed -e 's/\.so$/\.a/')
    if [ ! -e "$archive_file" ]; then
        echo -e "${RED}$so_file is orphan, no $archive_file found${NC}"
    fi
}

analyze_archive() {
    local archive_file
    archive_file=$1
    local so_file
    so_file=$(echo "$archive_file" | sed -e 's/\.a$/\.so/')
    if [ ! -e "$so_file" ]; then
        echo -e  "${RED}$archive_file is orphan, no $so_file found${NC}"
    fi
}

export -f analyze_so analyze_archive

pushd src/zetasql-*/bazel-bin/
find zetasql -maxdepth 4 -iname '*.so' -exec bash -c 'analyze_so $0' {} \;
find zetasql -iname '*.a' -exec bash -c 'analyze_archive $0' {} \;
popd
