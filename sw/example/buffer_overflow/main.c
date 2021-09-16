#include <neorv32.h>
#include <string.h>

#define BAUD_RATE 19200

char stringa[50] = "short string";
char stringb[50] = "a long string that will get truncated";
char *string[2] = {stringa, stringb};

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

int main(void) {
  // neorv32 setup
	neorv32_rte_setup(); // capture exceptions/debug info
  neorv32_uart_setup(BAUD_RATE, PARITY_NONE, FLOW_CONTROL_NONE); // uart init
    
  neorv32_uart_print("starting buffer overflow test\n");
  init();
	char buffer[28];
	void (**next_function)(char*) = (void*) buffer + 20;
	*next_function = good_function;

	receive_input(buffer);
	(*next_function)(buffer);
	receive_input(buffer);
	(*next_function)(buffer);
}
