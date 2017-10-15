# Finds the value of 2^3 + 5^2 by calling the power function (in power.asm) twice and summing up the two results.


.include "power.asm"

.section .data				# starting with period means assembler
					            # instructions and not machine code

.section .text				# where instructions live


.globl _main				# tell program to start at _start

_main:
    movl %esp, %ebp     #for correct debugging
    pushl $3				    # push 2nd argument
    pushl $2				    # push 1st argument
    call power			    # call the function
    addl $8, %esp			  # move stack pointer back

    pushl %eax			    # save 1st answer before calling
					              # the next function
	
    pushl $2				    # push 2nd argument
    pushl $5				    # push 1st argument
    call power			    # call the function
    addl $8, %esp			  # move stack pointer back

    popl %ebx			      # 2nd answer already in %eax, 1st answer
					              # on the stack so pop it into %ebx
	
    addl %eax, %ebx			# add them together

    movl $1, %eax			  # exit code (%ebx is returned)
    int $0x80			      # interrupt 16
