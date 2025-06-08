#!/bin/bash

/app/infra/bin/ce_install --filter-match-any install "libraries/c++/boost 1.82.0" "libraries/c++/nlohmann_json 3.11.1" "libraries/c++/eigen 3.4.0"

export JULIA_DEPOT_PATH="/opt/compiler-explorer/juliapackages"
/opt/compiler-explorer/julia-1.10.0/bin/julia -e 'using Pkg; Pkg.add("Enzyme")'
/opt/compiler-explorer/julia-1.11.2/bin/julia -e 'using Pkg; Pkg.add("Enzyme")'

curl -O https://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-3.19.4.tar.gz
tar xf petsc-3.19.4.tar.gz -C /opt/compiler-explorer/libs/
rm -r petsc-3.19.4.tar.gz
