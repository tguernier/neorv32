#!/bin/bash

# Abort if any command returns != 0
set -e

# Default simulation configuration
SIM_CONFIG=--stop-time=8ms

# Project home folder
homedir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
homedir=$homedir/../..

# The directories of the hw source files
srcdir_core=$homedir/rtl/core
srcdir_sim=$homedir/sim
srcdir_top_templates=$homedir/rtl/top_templates

# Show GHDL version
ghdl -v

# Simulation time define by user?
echo ""
if [ -z ${1} ]; then echo "Using default simulation config: $SIM_CONFIG"; else SIM_CONFIG=$1; echo "Using user simulation config: $SIM_CONFIG"; fi
echo ""

# List files
#echo "Simulation source files:"
#ls -l $srcdir_core
#ls -l $srcdir_sim
#ls -l $srcdir_top_templates
#echo ""

# Just a hint
echo "Tip: Compile application with USER_FLAGS+=-DUART[0/1]_SIM_MODE to auto-enable UART[0/1]'s simulation mode (redirect UART output to simulator console)."
echo ""

# Analyse sources; libs and images at first!
ghdl -a --work=neorv32 $srcdir_core/neorv32_package.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_application_image.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_bootloader_image.vhd
#
ghdl -a --work=neorv32 $srcdir_core/neorv32_boot_rom.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_busswitch.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_bus_keeper.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_icache.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_cfs.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_cpu.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_cpu_alu.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_cpu_bus.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_cpu_control.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_cpu_cp_bitmanip.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_cpu_cp_fpu.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_cpu_cp_muldiv.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_cpu_decompressor.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_cpu_regfile.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_dmem.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_gpio.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_imem.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_mtime.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_nco.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_neoled.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_pwm.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_spi.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_sysinfo.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_top.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_trng.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_twi.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_uart.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_wdt.vhd
ghdl -a --work=neorv32 $srcdir_core/neorv32_wishbone.vhd
#
ghdl -a --work=neorv32 $srcdir_top_templates/neorv32_test_setup.vhd
ghdl -a --work=neorv32 $srcdir_top_templates/neorv32_top_axi4lite.vhd
ghdl -a --work=neorv32 $srcdir_top_templates/neorv32_top_stdlogic.vhd
#
ghdl -a --work=neorv32 $srcdir_sim/neorv32_tb.vhd

# Prepare simulation output files for UART0
# Testbench receiver log file
touch neorv32.testbench_uart0.out
chmod 777 neorv32.testbench_uart0.out
# UART0 direct simulation output
touch neorv32.uart0.sim_mode.text.out
chmod 777 neorv32.uart0.sim_mode.text.out
touch neorv32.uart0.sim_mode.data.out
chmod 777 neorv32.uart0.sim_mode.data.out

# Prepare simulation output files for UART1
# Testbench receiver log file
touch neorv32.testbench_uart1.out
chmod 777 neorv32.testbench_uart1.out
# UART1 direct simulation output
touch neorv32.uart1.sim_mode.text.out
chmod 777 neorv32.uart1.sim_mode.text.out
touch neorv32.uart1.sim_mode.data.out
chmod 777 neorv32.uart1.sim_mode.data.out

# Run simulation
ghdl -e --work=neorv32 neorv32_tb
ghdl -r --work=neorv32 neorv32_tb --max-stack-alloc=0 --ieee-asserts=disable --assert-level=error $SIM_CONFIG
