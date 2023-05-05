#!/bin/bash

function show_usage {
   echo "Options: (gemm|trmm|syrk|syr2k|hemm|gemv|trmv|symv|ger) (a10|s10) (tiny|large) (hw|emulator) [bitstream]"
}

if [ $0 == $BASH_SOURCE ]; then
   echo "This script should be sourced, not run."
   exit
fi 

wrong_options=1

if [ "$1" != "gemm" -a "$1" != "trmm" -a "$1" != "syrk" -a "$1" != "syr2k" -a "$1" != "hemm" -a "$1" != "gemv" -a "$1" != "trmv" -a "$1" != "symv" -a "$1" != "ger" ]; then
    show_usage
    return
else
    workload="$1"
fi

if [ "$2" != "a10" -a "$2" != "s10" ]; then
    show_usage
    return
else
    target="$2"
fi

if [ "$3" != "tiny" -a "$3" != "large" ]; then
    show_usage
    return
else
    size="$3"
fi

if [ "$4" != "hw" -a "$4" != "emulator" ]; then
    show_usage
    return
else
    platform="$4"
fi

if [ "$5" != "" ]; then
    # Add prefix to the bitstream
    bitstream="$6/$2/a.aocx"
    echo "Use the bitstream ${bitstream}"
fi

if [ "$platform" == "emulator" ]; then
    if [ "$target" != "a10" -a "$target" != "s10" ]; then
        show_usage
        echo "Note: The emulator option is applicable only to FPGAs and tiny size"
        return
    elif [ "$size" != "tiny" ]; then
        show_usage
        echo "Note: The emulator option is applicable only to FPGAs and tiny size"
        return
    fi
fi

wrong_options=0
