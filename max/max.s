.section .data					        # starting with period means assembler
							                  # instructions and not machine code
data_items:
    .long 3, 67, 222, 45, 0			# array of longs, 5 x 4 bytes = 20 bytes

.section .text					        # where instructions live


.global _main  				          # tell program to start at _start
_main:
    movl %esp, %ebp                         #for correct debugging
    movl $0, %edi				                    # move 0 into the index register
    movl data_items(,%edi,4), %eax	        # load 1st byte of data
    movl %eax, %ebx				                  # 1st loop so %eax is the largest

start_loop:
    cmpl $0, %eax				                    # check to see if end of data
    je loop_exit				                    # jump if equal
    incl %edi					                      # increase index
    movl data_items(,%edi,4), %eax	        # load next byte of data
    cmpl %ebx, %eax				                  # compare values
    jle start_loop				                  # jump back if new value is smaller
    movl %eax, %ebx				                  # save value as the largest
    jmp start_loop				                  # jump back

loop_exit:						
    movl $1, %eax				          # 1 is exit code, % ebx is status code
    int $0x80					            # interrupt 16
