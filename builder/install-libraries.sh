#!/bin/bash

set -x

if /app/infra/bin/ce_install check-installed libraries/c++/boost 1.81.0 | grep "not installed"; then
    /app/infra/bin/ce_install install libraries/c++/boost 1.81.0
fi

if /app/infra/bin/ce_install check-installed libraries/c++/nlohmann_json 3.11.1 | grep "not installed"; then
    /app/infra/bin/ce_install install libraries/c++/nlohmann_json 3.11.1
fi

if /app/infra/bin/ce_install check-installed libraries/c++/eigen 3.4.0 | grep "not installed"; then
    /app/infra/bin/ce_install install libraries/c++/eigen 3.4.0
fi