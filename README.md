# Lasa
A Framework for Productive and Performant Linear Algebra on FPGAs

## Introduction
Linear algebra can often be significantly expedited by spatial accelerators on FPGAs. As a broadly-adopted linear algebra library, BLAS requires extensive optimizations for routines that vary vastly in data reuse, bottleneck resources, matrix storage layouts, and data types. Existing solutions are stuck in the dilemma of productivity and performance. 

We introduce Lasa, a framework composed of a programming model and a compiler, that addresses the dilemma by abstracting (for productivity) and specializing (for performance) the architecture of a spatial accelerator. Lasa abstracts a compute and its I/O as two dataflow graphs. A compiler maps the graphs onto systolic arrays and a customized memory heirarchy. The compiler further specializes the architecture transparently. In this framework, we develop 14 key BLAS routines, and demonstrate performance in parity with expert-written HLS code for BLAS level 3 routines, >=80% machine peak performance for level 2 and 1 routines, and 1.6X-7X speed up by taking advantage of matrix properties of symmetry, triangularity and bandness.

This project is built upon [T2SP](https://github.com/IntelLabs/t2sp).

## Installation
  
1. Download [Intel FPGA SDK for OpenCL](http://dl.altera.com/opencl/), and install with
  ```
  tar -xvf AOCL-pro-*-linux.tar 
  ./setup_pro.sh
  ```
2. Clone this repo and install the dependencies:
  ```
  git clone https://github.com/pku-liang/Lasa
  cd Lasa
  ./instll-tools.sh
  ```

The above `install-tools.sh` command installs llvm-clang >= 9.0, gcc >= 7.5.0, and python's numpy and matplotlib package. The command installs all of them and their dependencies we know to make the system self-contained. If your system has some of the tools already installed, you could edit `install-tools.sh` to disable the installations of these tools, then modify the environment setting as shown below.

The environment setting file is in `setenv.sh`:

+ If you have your own gcc, llvm or clang and thus did not use the above `install-tools.sh` command to install them, in `setenv.sh`, modify the following path variables appropriately:

  ```
  GCC_PATH=...
  export LLVM_CONFIG=...
  export CLANG=...
  ```

+ If you installed the Intel FPGA SDK for OpenCL for your local FPGA, check the following variables, and modify if needed:

  ```
  ALTERA_PATH=...
  AOCL_VERSION=...
  FPGA_BOARD_PACKAGE=...
  export FPGA_BOARD=...
  export LM_LICENSE_FILE=...
  ```

  Here is an example how to find out the board package and board (Assume Intel FPGA SDK for OpenCL 19.1 was installed under directory `$HOME/intelFPGA_pro`):

  ```
  $HOME/intelFPGA_pro/19.1/hld/bin/aoc -list-boards
     Board list:
       a10gx
         Board Package: $HOME/intelFPGA_pro/19.1/hld/board/a10_ref
    
       a10gx_hostpipe
         Board Package: $HOME/intelFPGA_pro/19.1/hld/board/a10_ref
  ```

  There are 1 board package and 2 boards in this case, and you should set `FPGA_BOARD_PACKAGE=a10_ref` and `export FPGA_BOARD=a10gx`.

3. Build Lasa
  ```
  cd Halide
  make -j
  ```

## Usage

Run a specific test:
  ```
  source ./setenv.sh
  cd BLAS
  ./test.sh (gemm|trmm|syrk|syr2k|hemm|herk|her2k|gemv|trmv|symv|ger|dot) (a10|s10) (tiny|large) (hw|emulator) [bitstream]
  ```

For example, `./test.sh gemm a10 large hw` to synthesize and run our GEMM design.  
`./test.sh gemm a10 large hw bitstream` to run the bitstream under `gemm/bitstream` directory.

Run all the tests (for correctness only):
  ```
  ./tests.sh (a10|s10)
  ``` 

## Publications

+ **Lasa: Abstraction and Specialization for Productive and Performant Linear Algebra on FPGAs**. 
Xiaochen Hao, Mingzhe Zhang, Ce Sun, Zhuofu Tao, Hongbo Rong, Yu Zhang, Lei He, Eric Petit, Wenguang Chen, Yun Liang. FCCM, 2023.

+ **SuSy: a programming model for productive construction of high-performance systolic arrays on FPGAs**. 
Yi-Hsiang Lai, Hongbo Rong, Size Zheng, Weihao Zhang, Xiuping Cui, Yunshan Jia, Jie Wang, Brendan Sullivan, Zhiru Zhang, Yun Liang, Youhui Zhang, Jason Cong, Nithin George, Jose Alvarez, Christopher Hughes, and Pradeep Dubey. 2020.  ICCAD'20. [Link](https://ieeexplore.ieee.org/document/9256583)

