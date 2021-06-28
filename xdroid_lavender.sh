#!/usr/bin/env bash
# Main
git clone https://github.com/xyzuan/proton-clang-build build
cd $(pwd)/build
./build-toolchain.sh
