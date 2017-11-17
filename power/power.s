.code32

.section .data				# starting with period means assembler
					# instructions and not machine code

.section .text				# where instructions live



.globl _start				# tell program to start at _start
_start:
	pushl $3			# push 2nd argument
	pushl $2			# push 1st argument
	call power			# call the function
	addl $8, %esp			# move stack pointer back

	pushl %eax			# save 1st answer before calling the next function

	pushl $2			# push 2nd argument
	pushl $5			# push 1st argument
	call power			# call the function
	addl $8, %esp			# move stack pointer back

	popl %ebx			# 2nd answer already in %eax, 1st answer
					# on the stack so pop it into %ebx

	addl %eax, %ebx			# add them together

	movl $1, %eax			# exit code (%ebx is returned)
	int $0x80			# interrupt 16





.type power, @function		  # tell linker this will be a function					
power:				
	#Epilogue
	pushl %ebp		      # save old base pointer
	movl %esp, %ebp		      # make stack pointer the base pointer
	subl $4, %esp		      # make room for local variables

	movl 8(%ebp), %ebx	      # put 1st argument in %ebx
	movl 12(%ebp), %ecx	      # put 2nd argument in %ecx
	movl %ebx, -4(%ebp)	      # store current result
	
power_loop_start:
	cmpl $1, %ecx		      # if the power is 1, end function
	je end_power			
	movl -4(%ebp), %eax 	      # move current result into %eax
	imull %ebx, %eax	      # multiply base number by current result
	movl %eax, -4(%ebp)	      # store current result

	decl %ecx		      # decrease the power
	jmp power_loop_start	      # run for the next power

end_power:
	movl -4(%ebp), %eax	      # return value goes in %eax
	
	#Prologue
	movl %ebp, %esp		      # restore stack pointer
	popl %ebp		      # restore base pointer 
	ret			      # popl %eip
