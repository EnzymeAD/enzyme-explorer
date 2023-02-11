#!/bin/bash

set +e

if /app/infra/bin/ce_install check-installed libraries/c++/boost 1.81.0 | grep "not installed"; then
    /app/infra/bin/ce_install install libraries/c++/boost 1.81.0
fi

if /app/infra/bin/ce_install check-installed libraries/c++/nlohmann_json 3.11.1 | grep "not installed"; then
    /app/infra/bin/ce_install install libraries/c++/nlohmann_json 3.11.1
fi

if /app/infra/bin/ce_install check-installed libraries/c++/eigen 3.4.0 | grep "not installed"; then
    /app/infra/bin/ce_install install libraries/c++/eigen 3.4.0
fi

export JULIA_DEPOT_PATH="/opt/compiler-explorer/juliapackages"
/opt/compiler-explorer/julia-1.8.5/bin/julia -e 'using Pkg; Pkg.add("Enzyme")'
