#!/bin/bash

# Abort if any command returns != 0
set -e

# Project home folder
homedir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
homedir=$homedir/..

# Check GCC toolchain installation
echo "--------------------------------------------------------------------------"
echo "> Checking RISC-V GCC toolchain..."
echo "--------------------------------------------------------------------------"
riscv32-unknown-elf-gcc -v

# Check GHDL installation
echo "--------------------------------------------------------------------------"
echo "> Checking GHDL simulator..."
echo "--------------------------------------------------------------------------"
ghdl -v

echo "--------------------------------------------------------------------------"
echo "> Checking 'riscv-arch-test' GitHub repository (submodule)..."
echo "--------------------------------------------------------------------------"

git submodule update --init

# Copy NEORV32 files
echo "--------------------------------------------------------------------------"
echo "> Making local copy of NEORV32 'rtl', 'sim' & 'sw' folders..."
echo "--------------------------------------------------------------------------"
(cd $homedir/riscv-arch-test/work ; rm -rf neorv32 ; mkdir neorv32)
cp -r $homedir/rtl/ $homedir/riscv-arch-test/work/neorv32/.
cp -r $homedir/sim/ $homedir/riscv-arch-test/work/neorv32/.
cp -r $homedir/sw/ $homedir/riscv-arch-test/work/neorv32/.

# Copy neorv32 target folder into test suite
echo "--------------------------------------------------------------------------"
echo "> Copying neorv32 test-target into riscv-arch-test framework..."
echo "--------------------------------------------------------------------------"
cp -rf $homedir/riscv-arch-test/port-neorv32/framework_v2.0/riscv-target/neorv32 $homedir/riscv-arch-test/work/riscv-arch-test/riscv-target/.

# Make a local copy of the original IMEM rtl file
echo ""
echo ">>> Making local backup of original IMEM rtl file (work/neorv32/rtl/core/neorv32_imem.ORIGINAL)..."
echo ""
cp $homedir/riscv-arch-test/work/neorv32/rtl/core/neorv32_imem.vhd $homedir/riscv-arch-test/work/neorv32/rtl/core/neorv32_imem.ORIGINAL

# Component installation done
ls -al
echo "--------------------------------------------------------------------------"
echo "> Component installation done!"
echo "--------------------------------------------------------------------------"
echo ""


# neorv32 home folder
NEORV32_LOCAL_HOME=$homedir/riscv-arch-test/work/neorv32

echo "--------------------------------------------------------------------------"
echo "> Starting RISC-V architecture tests..."
echo "--------------------------------------------------------------------------"

# Clean up everything
make -C $homedir/riscv-arch-test/work/riscv-arch-test NEORV32_LOCAL_COPY=$NEORV32_LOCAL_HOME XLEN=32 RISCV_TARGET=neorv32 clean


# work in progress FIXME
echo ""
echo "\e[1;33mWARNING! 'Zifencei' test is currently disabled (work in progress). \e[0m"
echo ""


# Run tests and check results
make --silent -C $homedir/riscv-arch-test/work/riscv-arch-test NEORV32_LOCAL_COPY=$NEORV32_LOCAL_HOME SIM_TIME=850us XLEN=32 RISCV_TARGET=neorv32 RISCV_DEVICE=I build run verify
make --silent -C $homedir/riscv-arch-test/work/riscv-arch-test NEORV32_LOCAL_COPY=$NEORV32_LOCAL_HOME SIM_TIME=400us XLEN=32 RISCV_TARGET=neorv32 RISCV_DEVICE=C build run verify
make --silent -C $homedir/riscv-arch-test/work/riscv-arch-test NEORV32_LOCAL_COPY=$NEORV32_LOCAL_HOME SIM_TIME=800us XLEN=32 RISCV_TARGET=neorv32 RISCV_DEVICE=M build run verify
make --silent -C $homedir/riscv-arch-test/work/riscv-arch-test NEORV32_LOCAL_COPY=$NEORV32_LOCAL_HOME SIM_TIME=200us XLEN=32 RISCV_TARGET=neorv32 RISCV_DEVICE=privilege build run verify
#make --silent -C $homedir/riscv-arch-test/work/riscv-arch-test NEORV32_LOCAL_COPY=$NEORV32_LOCAL_HOME SIM_TIME=200us XLEN=32 RISCV_TARGET=neorv32 RISCV_DEVICE=Zifencei RISCV_TARGET_FLAGS=-DNEORV32_NO_DATA_INIT build run verify

echo ""
echo "RISC-V architecture tests completed successfully"
