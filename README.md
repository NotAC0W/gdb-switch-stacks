Software can contain for various reasons multiple stacks which complicates diagnosis. GDB offers facilities to 
work with multiple stacks:

```
frame stack-addr [ pc-addr ]
f stack-addr [ pc-addr ]
  Select the frame at address stack-addr. This is useful mainly if the chaining of stack frames has
  been damaged by a bug, making it impossible for GDB to assign numbers properly to all frames. In
  addition, this can be useful when your program has multiple stacks and switches between them. The 
  optional pc-addr can also be given to specify the value of PC for the stack frame.
```

This repository contains a minimal example with two stacks and a python script that **should** print the backtrace of both
stacks, but fails to do so.


# Test case description
The program jumping\_stacks calls setup() which allocates space for a new stack on the heap, prepares it and jumps to the new stack with a function to execute. This function calls two additional functions and then encounters a fabricated crash.

Loading backtracing\_stacks.py into gdb adds the command 'bts' which prints the bt for both stacks invoked from the point
of the fabricated crash.

### Simple call tree
```
. main() calls setup()
.. setup() allocates place for a new stack on the heap
.. setup() calls create_stack(stack, new_world) which
... puts new_world on that stack as return address
... saves several register and EFLAGS on that stack
..  setup() calls switch_stack()
... saves registers and EFLAGS on current register
... changes sp to new stack
... recovers EFLAGS and registers
... returns to new_world()

. new_world calls asmfoo()
.. asmfoo calls asmfoo2()
... asmfoo2 has a segfault build in that crashes the program 
```


### Problem description

Invoking the 'bts' on the crash will print the current stack, but will have a "Invalid Frame" exception on printing the 
old stack.

The script first will print the current stack to show that working. Then it will jump within that stack to another frame
with the same methodology that is used to jump to the other stack showing that doing it within
the "current stack" works. Then it will selected the top frame on the other stack and try to print that
stack which fails.

Setting a break point on main.c:26 and inspecting the stack pointer shows that it is identical to the address determined 
by the script.


### Example run

With GNU 8.1

```
$ gdb ./jumping_stacks 
Reading symbols from ./jumping_stacks...done.
(gdb) source backtracing_stacks.py 
(gdb) b main.c:26
Breakpoint 1 at 0x6ff: file main.c, line 26.
(gdb) r
Starting program: /home/user/gdb/jumping_stacks 
Switching Stack

Breakpoint 1, setup () at main.c:26
26		switch_stack(&old_stack, bottom-64); 
(gdb) print $rsp
$1 = (void *) 0x7fffffffe1c0
(gdb) c
Continuing.
Hello Ding Dong

Program received signal SIGSEGV, Segmentation fault.
asmfoo2 () at functions.S:14
14		movq %r12, 0(%r12) #This is intentionally broken
(gdb) bts
Current Stack:
#0 0x000055555555474a in None()+13 at functions.S:14
#1 0x000055555555475c in None()+31 at functions.S:32
#2 0x00005555555546a4 in new_world()+26 at main.c:15
Stopped because pc = 0

Attempting to jump frame 'within' stack
#0 0x000055555555475c in None()+31 at functions.S:32
#1 0x00005555555546a4 in new_world()+26 at main.c:15
Stopped because pc = 0

Attempting to jump frame 'outof' stack
Old Stack: 0x7fffffffe180 PC Address 0x55555555475f
Frameline is +64: 0x7fffffffe1c0
Switching Stacks: select-frame 0x7fffffffe1c0 0x55555555475f
Old Stack:
Python Exception <class 'gdb.error'> Frame is invalid.: 
Error occurred in Python command: Frame is invalid.

```
