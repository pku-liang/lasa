#!/bin/bash

function show_usage {
    echo "Usage:"
    echo "  ./tests.sh (a10|s10)"
}       

# BASH_SOURCE is this script
if [ $0 != $BASH_SOURCE ]; then
    echo "Error: The script should be directly run, not sourced"
    return
fi

if [ "$1" != "a10" -a "$1" != "s10" ]; then
    show_usage
    exit
else
    target="$1"
fi

# The path to this script.
PATH_TO_SCRIPT="$( cd "$(dirname "$BASH_SOURCE" )" >/dev/null 2>&1 ; pwd -P )"

cur_dir=$PWD
cd $PATH_TO_SCRIPT

# FPGA: Verify correctness with tiny problem sizes and emulator
./test.sh gemm $target tiny emulator
./test.sh hemm $target tiny emulator
./test.sh trmm $target tiny emulator
./test.sh syrk $target tiny emulator
./test.sh syr2k $target tiny emulator
./test.sh gemv $target tiny emulator
./test.sh trmv $target tiny emulator
./test.sh symv $target tiny emulator
./test.sh ger $target tiny emulator

cd $cur_dir
