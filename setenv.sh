#!/bin/bash

if [ $0 == $BASH_SOURCE ]; then
   echo "This script should be sourced, not run."
   exit
fi

export T2S_PATH="$( cd "$(dirname $(realpath "$BASH_SOURCE") )" >/dev/null 2>&1 ; pwd -P )" # The path to this script
TOOLS_PATH=$HOME/llvm/

# Modify these 3 paths if you installed your own versions of gcc or llvm-clang
# gcc should be located at $GCC_PATH/bin
GCC_PATH=$TOOLS_PATH/gcc-7.5.0
export LLVM_CONFIG=$TOOLS_PATH/bin/llvm-config
export CLANG=$TOOLS_PATH/bin/clang

# Modify according to your machine's setting
ALTERA_PATH=$HOME/intelFPGA_pro
AOCL_VERSION=19.1
FPGA_BOARD_PACKAGE=a10_ref
export FPGA_BOARD=a10gx
export LM_LICENSE_FILE=1800@altera02p.elic.intel.com

#### No need to change below this point ##########

# Intel OpenCL related setting
export ALTERAOCLSDKROOT=$ALTERA_PATH/$AOCL_VERSION/hld
export INTELFPGAOCLSDKROOT=$ALTERAOCLSDKROOT
export AOCL_SO=$ALTERAOCLSDKROOT/host/linux64/lib/libalteracl.so
export AOCL_BOARD_SO=$ALTERA_PATH/$AOCL_VERSION/hld/board/${FPGA_BOARD_PACKAGE}/linux64/lib/libaltera_${FPGA_BOARD_PACKAGE}_mmd.so
export AOCL_LIBS="-L$ALTERA_PATH/$AOCL_VERSION/hld/board/${FPGA_BOARD_PACKAGE}/host/linux64/lib -L$ALTERA_PATH/$AOCL_VERSION/hld/board/${FPGA_BOARD_PACKAGE}/linux64/lib -L$ALTERA_PATH/$AOCL_VERSION/hld/host/linux64/lib -Wl,--no-as-needed -lalteracl -laltera_${FPGA_BOARD_PACKAGE}_mmd"
export QSYS_ROOTDIR=$ALTERAOCLSDKROOT/../qsys/bin
export QUARTUS_ROOTDIR_OVERRIDE=$ALTERAOCLSDKROOT/../quartus
export LD_LIBRARY_PATH=$ALTERAOCLSDKROOT/host/linux64/lib:$ALTERAOCLSDKROOT/board/${FPGA_BOARD_PACKAGE}/linux64/lib:$LD_LIBRARY_PATH
export PATH=$QUARTUS_ROOTDIR_OVERRIDE/bin:$ALTERAOCLSDKROOT/bin:$PATH
source $ALTERAOCLSDKROOT/init_opencl.sh
unset CL_CONTEXT_EMULATOR_DEVICE_ALTERA
export EMULATOR_LIBHALIDE_TO_LINK="-lHalide"
export HW_LIBHALIDE_TO_LINK="-lHalide"
# Figure out aoc options for emulator
if [ "$AOC_VERSION" != "19.2.0" ]; then
    export EMULATOR_AOC_OPTION="-march=emulator"
else
    export EMULATOR_AOC_OPTION="-march=emulator -legacy-emulator"
fi

#A place to store generated Intel OpenCL files
mkdir -p ~/tmp

# Add tools
export PATH=$TOOLS_PATH/bin:$PATH
export LD_LIBRARY_PATH=$TOOLS_PATH/lib64:$TOOLS_PATH/lib:$LD_LIBRARY_PATH

# Add gcc
export PATH=$GCC_PATH/bin:$PATH
export LD_LIBRARY_PATH=$GCC_PATH/bin:$GCC_PATH/lib64:$LD_LIBRARY_PATH

# Add Halide
export PATH=$T2S_PATH/Halide/bin:$PATH
export LD_LIBRARY_PATH=$T2S_PATH/Halide/bin:$LD_LIBRARY_PATH

# Common options for compiling a specification
export COMMON_OPTIONS_COMPILING_SPEC="-I $T2S_PATH/Halide/include -L $T2S_PATH/Halide/bin -lz -lpthread -ldl -std=c++11"

# Common options for running a specification to synthesize a kernel for emulation or execution
export COMMON_AOC_OPTION_FOR_EMULATION="$EMULATOR_AOC_OPTION -board=$FPGA_BOARD -emulator-channel-depth-model=strict"
export COMMON_AOC_OPTION_FOR_EXECUTION="-v -profile -fpc -fp-relaxed -board=$FPGA_BOARD"

# Common options for comping a host file
export COMMON_OPTIONS_COMPILING_HOST="$T2S_PATH/t2s/src/AOT-OpenCL-Runtime.cpp $T2S_PATH/t2s/src/Roofline.cpp $T2S_PATH/t2s/src/SharedUtilsInC.cpp -DLINUX -DALTERA_CL -fPIC -I$T2S_PATH/t2s/src/ -I $T2S_PATH/Halide/include -I$INTELFPGAOCLSDKROOT/examples_aoc/common/inc $INTELFPGAOCLSDKROOT/examples_aoc/common/src/AOCLUtils/opencl.cpp $INTELFPGAOCLSDKROOT/examples_aoc/common/src/AOCLUtils/options.cpp -I$INTELFPGAOCLSDKROOT/host/include -L$INTELFPGAOCLSDKROOT/linux64/lib -L$AOCL_BOARD_PACKAGE_ROOT/linux64/lib -L$INTELFPGAOCLSDKROOT/host/linux64/lib -lOpenCL -L $T2S_PATH/Halide/bin -lelf -lz -lpthread -ldl -std=c++11"
export COMMON_OPTIONS_COMPILING_HOST_FOR_EMULATION="$COMMON_OPTIONS_COMPILING_HOST $EMULATOR_LIBHALIDE_TO_LINK"
export COMMON_OPTIONS_COMPILING_HOST_FOR_EXECUTION="$COMMON_OPTIONS_COMPILING_HOST $HW_LIBHALIDE_TO_LINK"
