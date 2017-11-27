.type count_chars, @function
.globl count_chars


.equ ST_STRING_START_ADDRESS, 8

count_chars:
pushl %ebp
movl %esp, %ebp

movl $0, %ecx				# counter starts at zero
					

movl ST_STRING_START_ADDRESS(%ebp), %edx	# starting address of data

count_loop_begin:
movb (%edx), %al		# grab the current character

cmpb $0, %al			# is it null?

je count_loop_end		# if yes, we’re done

incl %ecx			# otherwise, increment the counter
incl %edx			# and the pointer

jmp count_loop_begin		# go back to the beginning of the loop

count_loop_end:
movl %ecx, %eax		# move count to %eax

popl %ebp			# restore base pointer
ret				# pop %eip
