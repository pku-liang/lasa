#!/bin/bash

function cleanup {
    rm -rf a.* a a/ ${workload}-interface.* *.out exec_time.txt *.png *.o *.isa ${workload}_genx.cpp signed* temp* profile.mon
}

function libhalide_to_link {
    if [ "$platform" == "emulator" ]; then
        lib="$EMULATOR_LIBHALIDE_TO_LINK"
    else
        lib="$HW_LIBHALIDE_TO_LINK"
    fi
    echo "$lib"
}

function aoc_options {
    if [ "$platform" == "emulator" ]; then
        aoc_opt="$EMULATOR_AOC_OPTION -board=$FPGA_BOARD -emulator-channel-depth-model=strict"
    else
        aoc_opt="-v -profile -fpc -fp-relaxed -high-effort -board=$FPGA_BOARD"
    fi
    echo "$aoc_opt"
}

function generate_fpga_kernel {
    # Compile the specification
    g++ ${workload}.cpp -g -I ../util -I $T2S_PATH/Halide/include -L $T2S_PATH/Halide/bin $(libhalide_to_link) -lz -lpthread -ldl -std=c++11 -D$size

    # Generate a device kernel, and a C interface for the host to invoke the kernel:
    # The bitstream generated is a.aocx, as indicated by the environment variable, BITSTREAM.
    # The C interface generated is ${workload}-interface.cpp, as specified in ${workload}.cpp.
    env BITSTREAM=$bitstream AOC_OPTION="$(aoc_options)" ./a.out

    # DevCloud A10PAC (1.2.1) only: further convert the signed bitstream to unsigned:
    if [ "$target" == "a10" -a "$platform" == "hw" ]; then
        cp $bitstream a_signed.aocx # Keep a signed copy in case the conversion fails below and we can look at the issue manually
        { echo "Y"; echo "Y"; echo "Y"; echo "Y"; } | source $AOCL_BOARD_PACKAGE_ROOT/linux64/libexec/sign_aocx.sh -H openssl_manager -i $bitstream -r NULL -k NULL -o a_unsigned.aocx
        mv a_unsigned.aocx $bitstream
    fi
}

function test_fpga_kernel {
    # Compile the host file (${workload}-run-fpga.cpp) and link with the C interface (${workload}-interface.cpp):
    g++ ${workload}-run-fpga.cpp ${workload}-interface.cpp ../../t2s/src/AOT-OpenCL-Runtime.cpp ../../t2s/src/Roofline.cpp ../../t2s/src/SharedUtilsInC.cpp  -g -DLINUX -DALTERA_CL -fPIC -I ../util -I../../t2s/src/ -I $T2S_PATH/Halide/include -I../../t2s/src/AOCLUtils ../../t2s/src/AOCLUtils/opencl.cpp $(aocl compile-config) $(aocl link-config) -L $T2S_PATH/Halide/bin -lelf $(libhalide_to_link) -D$size -lz -lpthread -ldl -std=c++11 -o ./b.out

    if [ "$platform" == "emulator" ]; then
        env BITSTREAM="$bitstream" CL_CONTEXT_EMULATOR_DEVICE_INTELFPGA=1 INTEL_FPGA_OCL_PLATFORM_NAME="$EMULATOR_PLATFORM" ./b.out
    else
        # Offload the bitstream to the device.
        aocl program acl0 "$bitstream"

        # Run the host binary. The host offloads the bitstream to an FPGA and invokes the kernel through the interface:
        env BITSTREAM="$bitstream" INTEL_FPGA_OCL_PLATFORM_NAME="$HW_PLATFORM" ./b.out
    fi
}

function generate_test_fpga_kernel {
    source ../setenv.sh
    cd $workload
    if [ "$target" == "s10" -a "$size" == "LARGE" ]; then
        size="S10"
    fi
    if [ "$bitstream" == "" ]; then
        echo "Use the default bitstream $(pwd)/${bitstream}"
        bitstream="a.aocx"
    fi
    cleanup
    generate_fpga_kernel
    test_fpga_kernel
}
