#!/bin/bash

set +e

/app/infra/bin/ce_install --filter-match-any install "compilers/c++/clang 9.0.1" "compilers/c++/clang 10.0.1" "compilers/c++/clang 11.0.1" "compilers/c++/clang 12.0.1" "compilers/c++/clang 13.0.1" "compilers/c++/clang 14.0.0" "compilers/c++/clang 15.0.0" "compilers/c++/clang 16.0.0" "compilers/c++/mlir 16.0.0" "compilers/julia 1.8.5"

