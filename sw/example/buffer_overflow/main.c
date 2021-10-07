// A demonstration program for a buffer overflow attack.
// On an unmodified system bad_function would be called, but with DIFT the attack is caught
// Has to be compiled with EFFORT -O0

#include <neorv32.h>
#include <string.h>

#define BAUD_RATE 19200
#define SIZE 50

char stringa[SIZE] = "short string";
char stringb[SIZE] = "a long string that will get truncated";
char *string[2] = {stringa, stringb};

// prototypes
void dift_exception_handler(void);
void print_hex_word(uint32_t num);
void good_function(char* buffer);
void bad_function(char* buffer);
void recieve_input(char* buffer);
void init();
void array_settag(char* array_ptr, int size);

void dift_exception_handler(void) {
  // this function will be run when the DIFT system detects tagged data being used in an unsafe way 
  // (e.g. used to change the program counter)
  uint32_t epc = neorv32_cpu_csr_read(CSR_MEPC);
  neorv32_uart_printf("DIFT tag check exception at: ");
  print_hex_word(epc);
  neorv32_uart_printf("\n");
  neorv32_cpu_sleep(); // stall CPU
}

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

void good_function(char *buffer) {
  neorv32_uart_printf("good function %s\n", buffer);
}

void bad_function(char *buffer) {
  neorv32_uart_printf("bad function %s\n", buffer);
}

void receive_input(char *buffer) {
	static int i = 0;
	strcpy(buffer, string[i]);
	i++;
}

void init() {
	void (**q)(char*) = (void*) string[1] + 20;
	*q = bad_function;
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

int main(void) {
  // init CPU
  neorv32_rte_setup();
  neorv32_uart_setup(BAUD_RATE, PARITY_NONE, FLOW_CONTROL_NONE);

  // init DIFT system
  // neorv32_cpu_csr_write(CSR_DIFTPROP, 0x00000222); // set tag propagation register
  // neorv32_cpu_csr_write(CSR_DIFTCHK, 0x00008000); // set tag check register
  // neorv32_cpu_eint(); // enable interrupts
  // neorv32_rte_exception_install(RTE_TRAP_NMI, dift_exception_handler); // set exception handler routine
  
  // init string
  init();

  // tag strings (simulated input)
  // array_settag(stringa, SIZE);
  // array_settag(stringb, SIZE);
  
	neorv32_uart_printf("Buffer overflow demonstration program:\n");
  
  char buffer[28];
	void (**next_function)(char*) = (void*) buffer + 20;
	*next_function = good_function;

	receive_input(buffer);
	(*next_function)(buffer); // calls good_function()
	receive_input(buffer);
	(*next_function)(buffer); // would call bad_function() on unmodified system, shouldn't execute on DIFT system
}
