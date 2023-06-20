#!/bin/bash

/app/infra/bin/ce_install --filter-match-any install "libraries/c++/boost 1.82.0" "libraries/c++/nlohmann_json 3.11.1" "libraries/c++/eigen 3.4.0"

export JULIA_DEPOT_PATH="/opt/compiler-explorer/juliapackages"
/opt/compiler-explorer/julia-1.8.5/bin/julia -e 'using Pkg; Pkg.add("Enzyme")'
