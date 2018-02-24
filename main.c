#include <stdio.h>
#include <stdlib.h>
#include <memory.h>

void asmfoo();
void create_stack(char *stack, char *func);
void switch_stack(char **old_stack, char *new_stack);


char *old_stack = NULL;

void new_world() {
	printf("Hello Ding Dong\n");
	asmfoo();
}

void setup() {
	size_t size = 1 << 13;
	char *block = (char *)malloc(size);
	char *bottom = block+size-16;
	// Sets the entry point up, takes 64 bytes on the stack
	create_stack(bottom, (char *)new_world);
	printf("Switching Stack\n");
	// Saves current state (64 bytes) on the current stack
	// and jumps to the entry point of the next stack
	switch_stack(&old_stack, bottom-64); 

}

int main(int argc, char *argv[]) {
	setup();
}
