// A demonstration program for a format string attack
// On an unmodified system inputting C format string specifiers (e.g. %d, %s) will cause program data to be printed

#include <neorv32.h>

#define BAUD_RATE 19200
#define SIZE 50

void print_hex_word(uint32_t num) {
  // function written by S. T. Nolting
  static const char hex_symbols[16] = "0123456789abcdef";
  neorv32_uart_printf("0x");

  int i;
  for (i=0; i<8; i++) {
    uint32_t index = (num >> (28 - 4*i)) & 0xF;
    neorv32_uart_putc(hex_symbols[index]);
  }
}

void dift_exception_handler(void) {
  // this function will be run when the DIFT system detects tagged data being used in an unsafe way 
  // (e.g. used to change the program counter)
  uint32_t epc = neorv32_cpu_csr_read(CSR_MEPC);
  neorv32_uart_printf("DIFT tag check exception at: ");
  print_hex_word(epc);
  neorv32_uart_printf("\n");
}

void array_settag(char *array_ptr, int size) {
  for (int i = 0; i < size; i++) {
    asm volatile
    (
      "settag x0, 0(%[offset]);"
      :
      :[offset] "r" (array_ptr)
    );
    array_ptr+=2;
  }
}

int main() {
  char buffer[SIZE];
  int size;
  
  // base system setup
  neorv32_rte_setup();
  neorv32_uart_setup(BAUD_RATE, PARITY_NONE, FLOW_CONTROL_NONE);
  
  // init DIFT system
  neorv32_cpu_csr_write(CSR_DIFTPROP, 0x00000222); // set tag propagation register
  neorv32_cpu_csr_write(CSR_DIFTCHK, 0x0000d000); // set tag check register, PC + load/store rs1 + alu
  neorv32_cpu_eint(); // enable interrupts
  neorv32_rte_exception_install(RTE_TRAP_NMI, dift_exception_handler); // set exception handler routine
  
  // loop forever
  while (1) {
    // read user input
    size = neorv32_uart_scan(buffer, 50, 1);
    neorv32_uart_print("\n");
    
    // tag input
    array_settag(buffer, SIZE);

    // print unsafely
    // safe printf call:
    // neorv32_uart_printf("%s", buffer);
    neorv32_uart_print("User inputted: ");
    neorv32_uart_printf(buffer);
    neorv32_uart_print("\n");
  }
  return 0;
}
