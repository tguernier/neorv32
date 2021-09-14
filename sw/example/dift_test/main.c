// this program requires a modified version of the RISC-V toolchain (for the settag instruction)

#include <neorv32.h>

/** UART BAUD rate */
#define BAUD_RATE 19200

// dift test program
int main() {
  // init DIFT tag propagation and check registers
  neorv32_cpu_csr_write(CSR_DIFTPROP , 0x00000222);
  neorv32_cpu_csr_write(CSR_DIFTCHK , 0x0000d600);
  
  int value = 1;
  int* address = &value;

  int a,b;

  // set tag of value
  asm volatile
  (
    "settag x0, 0(%[offset]);"
    :
    :[offset] "r" (address)
  );

  // some operations to test dift tag propagation
  a = value + 2;
  b = a - 1;
  value = a + b;
}

