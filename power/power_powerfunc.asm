# Finds the value of a number raised to another number. Called as a function

.text

.globl power
#.type power, @function			# tell linker this will be a function (doesn't work in SASM with this line)

power:				
	pushl %ebp			            # save old base pointer
	movl %esp, %ebp			        # make stack pointer the base pointer
	subl $4, %esp			          # make room for local variables

	movl 8(%ebp), %ebx		      # put 1st argument in %ebx
	movl 12(%ebp), %ecx		      # put 2nd argument in %ecx
	movl %ebx, -4(%ebp)		      # store current result
	
power_loop_start:
	cmpl $1, %ecx			          # if the power is 1, end function
	je end_power			
	movl -4(%ebp), %eax		      # move current result into %eax
	imull %ebx, %eax			      # multiply base number 
					                    # by current result
	movl %eax, -4(%ebp)		      # store current result

	decl %ecx			              # decrease the power
	jmp power_loop_start		    # run for the next power

end_power:
	movl -4(%ebp), %eax		      # return value goes in %eax
	
	movl %ebp, %esp			        # restore stack pointer
	popl %ebp			              # restore base pointer 
	ret				                   # popl %eip
