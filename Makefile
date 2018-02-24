.PHONY: all clean

all: jumping_stacks

clean:
	rm -f jumping_stacks

jumping_stacks: main.c functions.S
	gcc -o $@ -g -fomit-frame-pointer $^
