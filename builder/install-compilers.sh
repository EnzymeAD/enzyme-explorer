#!/bin/bash

-set +e

# clang

if /app/infra/bin/ce_install check-installed compilers/c++/clang 7.1.0 | grep "not installed"; then
    /app/infra/bin/ce_install install compilers/c++/clang 7.1.0
fi

if /app/infra/bin/ce_install check-installed compilers/c++/clang 8.0.1 | grep "not installed"; then
    /app/infra/bin/ce_install install compilers/c++/clang 8.0.1
fi

if /app/infra/bin/ce_install check-installed compilers/c++/clang 9.0.1 | grep "not installed"; then
    /app/infra/bin/ce_install install compilers/c++/clang 9.0.1
fi

if /app/infra/bin/ce_install check-installed compilers/c++/clang 10.0.1 | grep "not installed"; then
    /app/infra/bin/ce_install install compilers/c++/clang 10.0.1
fi

if /app/infra/bin/ce_install check-installed compilers/c++/clang 11.0.1 | grep "not installed"; then
    /app/infra/bin/ce_install install compilers/c++/clang 11.0.1
fi

if /app/infra/bin/ce_install check-installed compilers/c++/clang 12.0.1 | grep "not installed"; then
    /app/infra/bin/ce_install install compilers/c++/clang 12.0.1
fi

if /app/infra/bin/ce_install check-installed compilers/c++/clang 13.0.1 | grep "not installed"; then
    /app/infra/bin/ce_install install compilers/c++/clang 13.0.1
fi

if /app/infra/bin/ce_install check-installed compilers/c++/clang 14.0.0 | grep "not installed"; then
    /app/infra/bin/ce_install install compilers/c++/clang 14.0.0
fi

if /app/infra/bin/ce_install check-installed compilers/c++/clang 15.0.0 | grep "not installed"; then
    /app/infra/bin/ce_install install compilers/c++/clang 15.0.0
fi

# cuda

if /app/infra/bin/ce_install check-installed compilers/cuda 11.0.2 | grep "not installed"; then
    /app/infra/bin/ce_install install compilers/cuda 11.0.2
fi

# julia

if /app/infra/bin/ce_install check-installed compilers/julia 1.8.5 | grep "not installed"; then
    /app/infra/bin/ce_install install compilers/julia 1.8.5
fi
