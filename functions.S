.code64


.globl asmfoo2
.type asmfoo2, @function;
asmfoo2:
.cfi_startproc
.cfi_def_cfa rsp, 8
	pushq %r12
.cfi_adjust_cfa_offset 8
	subq $8, %rsp
.cfi_adjust_cfa_offset 8
	movq $0, %r12
	movq %r12, 0(%r12) #This is intentionally broken
	addq $8, %rsp
.cfi_adjust_cfa_offset -8
	popq %r12
.cfi_adjust_cfa_offset -8
	retq
.cfi_endproc
.size asmfoo2, .-asmfoo2


.globl asmfoo
.type asmfoo, @function;
asmfoo:
.cfi_startproc
.cfi_def_cfa rsp, 8
	pushq %r12
.cfi_adjust_cfa_offset 8
	call asmfoo2
	popq %r12
.cfi_adjust_cfa_offset -8
	retq
.cfi_endproc
.size asmfoo, .-asmfoo

.globl switch_stack
.type switch_stack, @function;
switch_stack:
.cfi_startproc
.cfi_def_cfa rsp, 8
        subq $48, %rsp
.cfi_adjust_cfa_offset 48
        movq %rbp, 40(%rsp)
        movq %rbx, 32(%rsp)
        movq %r12, 24(%rsp)
        movq %r13, 16(%rsp)
        movq %r14, 8(%rsp)
        movq %r15, 0(%rsp)
        pushfq
.cfi_adjust_cfa_offset 8
		movq %rsp, (%rdi)
        movq %rsi, %rsp
        popfq
.cfi_adjust_cfa_offset -8
        movq 0(%rsp), %r15
        movq 8(%rsp), %r14
        movq 16(%rsp), %r13
        movq 24(%rsp), %r12
        movq 32(%rsp), %rbx
        movq 40(%rsp), %rbp
        addq $48, %rsp
.cfi_adjust_cfa_offset -48
        retq
.cfi_endproc
.size switch_stack, .-switch_stack

.globl create_stack
.type create_stack, @function;
create_stack:
		pushq %rdx
		movq %rsp, %rdx
		movq %rdi, %rsp
		push %rsi
		subq $56, %rsp
		movq %rbp, 48(%rsp)
		movq %rbx, 40(%rsp)
		movq %r12, 32(%rsp)
		movq %r13, 24(%rsp)
		movq %r14, 16(%rsp)
		movq %r15, 8(%rsp)
		movq $0x0202, 0(%rsp) #default EFLAG values
		movq %rdx, %rsp
		popq %rdx
        retq
.size create_stack, .-create_stack
