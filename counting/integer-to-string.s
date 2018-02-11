    # %ecx will hold the count of characters processed
    # %eax will hold the current value
    # %edi will hold the base (10)

    .equ ST_VALUE, 8
    .equ ST_BUFFER, 12

    .globl integer2string
    .type integer2string, @function

integer2string:
    # Normal function beginning
    pushl %ebp
    movl %esp, %ebp

    movl $0, %ecx			# current character count

    movl ST_VALUE(%ebp), %eax		# move the value into position

    movl $10, %edi			# to divide by 10, the 10 must be in a 					
                            # register or memory location

conversion_loop:
    # Division is performed on the combined %edx:%eax register, 
    movl $0, %edx		# so first clear out %edx

    # Store the quotient in %eax, remainder in %edx (both are implied)
    divl %edi		# divide %edx:%eax (which are implied) by 10

    # Quotient is in %eax
    # Remainder in %edx, which now needs to be converted into a number. 
    # 	So, %edx has a number 0 – 9, an index on the ASCII table 
    # 	e.g. ascii ’0’ + integer 0 = ascii ’0’
    #	e.g. ascii ’0’ + integer 1 = ascii ’1’
    addl $’0’, %edx		# gives us character for the number stored in %edx

    # Push this value on the stack. When we are done, we can pop off the characters one-by-
    # one and they  will be in the right order. 
    # Note: We are pushing the whole register, but we only need the byte in %dl (the last 
    # byte of the %edx register) for the character.
    pushl %edx

    incl %ecx		# increment the digit count

    cmpl $0, %eax		# check if %eax is zero yet, go to next step if so.

    je end_conversion_loop

    # %eax already has its new value.

    jmp conversion_loop

end_conversion_loop:
    # The string is now on the stack, if we pop it off a character at a time we can copy it # into the buffer  and be done.

    movl ST_BUFFER(%ebp), %edx		# get the pointer to the buffer in %edx

copy_reversing_loop:
    # We pushed a whole register, but we only need the last byte. So we will pop off to the 
    # entire %eax register, but then only move the small part (%al) into the character string.
    popl %eax

    movb %al, (%edx)

    decl %ecx		# decreasing %ecx so we know when we are finished

    incl %edx		# increasing %edx so that it will be pointing to the next byte

    cmpl $0, %ecx			# check to see if we are finished

    je end_copy_reversing_loop		# if so, jump to the end of the function

    jmp copy_reversing_loop		# otherwise, repeat the loop

end_copy_reversing_loop:
    # Done copying
    movb $0, (%edx)	# now write a null byte and return

    # Normal function end
    movl %ebp, %esp
    popl %ebp
    ret
