.section .data 		 # this program has no global data

.section .text

.globl _main
_main:
	movl %esp, %ebp         #for correct debugging
	push $4		    		# one argument only
	call factorial		    # run the factorial function
	addl $4, %esp		    # scrubs the parameter that 
						  	# was pushed on the stack
	movl %eax, % ebx	    # factorial returns answer in %eax, but we want it in %ebx 
			  				# as exit status

	movl $1, %eax			# call kernel’s exit function
	int $0x80				# interrupt 16


.type factorial, @function		# tell linker this will be a function
factorial:				
	# Prologue
	pushl %ebp		        # save old base pointer
	movl %esp, %ebp		    # make stack pointer the base pointer

	movl 8(%ebp), %eax		# move 1st argument into %eax
	cmpl $1, %eax		    # base case so we return (return value %eax already 1)
	je end_factorial
	decl %eax			    # otherwise, decrease the value
	pushl %eax		        # push it for our call to factorial
	call factorial		    # call the factorial function
	movl 8(%ebp), %ebx		# %eax has return value so reload our parameter into %ebx
	imull %ebx, %eax		# multiply that by the last result of factorial, a
							# answer stored in %eax (already return value)

end_factorial:
	# Epilogue
	movl %ebp, %esp		    # restore stack pointer
	popl %ebp			    # restore base pointer 
	ret			            # popl %eip
