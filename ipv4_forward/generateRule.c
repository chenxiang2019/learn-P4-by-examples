#include <stdio.h>

int main() {
	for (int i = 3; i <= 102; i++) {
		printf("table_add l3_forward forward 10.%d.0.2/24 => 1\n", i);
	}
	printf("table_add l3_forward forward 10.0.0.2/24 => 2\n");
	return 0;
}