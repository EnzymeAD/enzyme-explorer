#!/bin/bash

/app/infra/bin/ce_install --filter-match-any install "compilers/c++/clang 11.0.1" "compilers/c++/clang 12.0.1" "compilers/c++/clang 13.0.1" "compilers/c++/clang 14.0.0" "compilers/c++/clang 15.0.0" "compilers/c++/clang 16.0.0" "compilers/c++/clang 17.0.1" "compilers/c++/mlir 16.0.0" "compilers/julia 1.8.5" "compilers/julia 1.9.3" "compilers/julia 1.10.0"

/app/infra/bin/ce_install --enable nightly install "compilers/c++/nightly/clang assertions-trunk"

/app/infra/bin/ce_install install "compilers/cuda 11.8.0" 
