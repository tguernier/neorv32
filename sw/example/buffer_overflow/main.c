#include <neorv32.h>
#include <string.h>

#define BAUD_RATE 19200
#define SIZE 50

char stringa[SIZE] = "short string";
char stringb[SIZE] = "a long string that will get truncated";
char *string[2] = {stringa, stringb};

volatile int a, b;

void good_function(char *buffer) {
  a = 0x00C0DDAD;
}

void bad_function(char *buffer) {
  b = 0xDEADBEEF;
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
    array_ptr++;
  }
}

int main(void) {
  // init DIFT system
  neorv32_cpu_csr_write(CSR_DIFTPROP, 0x00000222); // set tag propagation register
  neorv32_cpu_csr_write(CSR_DIFTCHK, 0x00008000); // set tag check register
  neorv32_cpu_eint(); // enable interrupts
  
  // init string
  init();

  // tag strings (simulated input)
  array_settag(stringa, SIZE);
  array_settag(stringb, SIZE);
  
	char buffer[28];
	void (**next_function)(char*) = (void*) buffer + 20;
	*next_function = good_function;

	receive_input(buffer);
	(*next_function)(buffer); // calls good_function()
	receive_input(buffer);
	(*next_function)(buffer); // would call bad_function() on unmodified system, shouldn't execute on DIFT system
}
