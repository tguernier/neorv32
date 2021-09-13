// this program requires a modified version of the RISC-V toolchain (for the settag instruction)

#include <neorv32.h>

/** UART BAUD rate */
#define BAUD_RATE 19200

// dift test program
int main() {
  // init DIFT tag propagation and check registers
  neorv32_cpu_csr_write(CSR_DIFTPROP , 0x000007ff);
  neorv32_cpu_csr_write(CSR_DIFTCHK , 0x0001ffff);
  
  int value = 1;
  int* address = &value;

  asm volatile
  (
    "settag x0, 0(%[offset]);"
    :
    :[offset] "r" (address)
  );
}

