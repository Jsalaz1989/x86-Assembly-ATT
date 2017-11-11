.section .data 		

# system call numbers
.equ SYS_OPEN, 5
.equ SYS_WRITE, 4
.equ SYS_READ, 3
.equ SYS_CLOSE, 6
.equ SYS_EXIT, 1

# options for open
.equ O_RDONLY, 0
.equ O_CREAT_WRONLY_TRUNC, 03101

# standard file descriptors
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERROR, 2

.equ LINUX_SYSCALL, 0x80		    # system call interrupt

.equ END_OF_FILE, 0			    # return value of read, meaning we’ve hit end of file

.equ NUMBER_ARGUMENTS, 2



.section .bss
.equ BUFFER_SIZE, 500			    	# buffer size = 500 bytes
.lcomm BUFFER_DATA, BUFFER_SIZE			# actual buffer

.section .text

# stack positions: where in the stack to find each piece of data
.equ ST_SIZE_RESERVE, 8		    	# buffer size
.equ ST_FD_IN, -4			# input file descriptor
.equ ST_FD_OUT, -8			# output file descriptor
.equ ST_ARGC, 0			        # number of arguments
.equ ST_ARGV_0, 4			# name of program
.equ ST_ARGV_1, 8			# input file name
.equ ST_ARGV_2, 12			# output file name

.globl _main
_main:
  ### INITIALIZE PROGRAM ###
  movl %esp, %ebp			    # save stack pointer
  subl $ST_SIZE_RESERVE, %esp		    # allocate space on stack for file descriptors	

open_files:

open_fd_in:
  ### OPEN INPUT FILE ###
  movl $SYS_OPEN, %eax		      # open input file (syscall 5) 
  movl ST_ARGV_1(%ebp), %ebx	      # input filename from command line into %ebx (%ebx now contains
                                      # pointer in the stack to null-terminated string)
  movl $O_RDONLY, %ecx		      # read-only flag
  movl $0666, %edx	  	      # permissions when creating file (this doesn’t really matter 
                                      # for reading)
  int $LINUX_SYSCALL		      # execute system call
                                      # Linux returns file descriptor in %eax

store_fd_in:				
  movl %eax, ST_FD_IN(%ebp)	      # transfer file descriptor from %eax
				      # to its appropriate place in the stack
open_fd_out:
  ### OPEN OUTPUT FILE ###
  movl $SYS_OPEN, %eax		      # open output file (syscall 5) 
  movl ST_ARGV_2(%ebp), %ebx	      # output filename from command line into %ebx (%ebx now contains
                                      # pointer in the stack to null-terminated string)
  movl $O_CREAT_WRONLY_TRUNC, %ecx	# write-only flag
  movl $0666, %edx		                # permissions when creating file:
                                      # write-only, create-if-doesn’t-exist, 
                                      # truncate-if-doesn’t-exist
  int $LINUX_SYSCALL		              # execute system call
                                      # Linux returns file descriptor in %eax

store_fd_out:					
  movl %eax, ST_FD_OUT(%ebp)	        # transfer file descriptor from %eax 
				                              # to its appropriate place in the stack


### BEGIN MAIN LOOP ###
read_loop_begin:
  ### READ IN A BLOCK FROM THE INPUT FILE ###
  movl $SYS_READ, %eax		            # read input file (syscall 3) 
  movl ST_FD_IN(%ebp), %ebx	          # get input file descriptor
  movl $BUFFER_DATA, %ecx		          # location to read from
  movl $BUFFER_SIZE, %edx		          # size of buffer
  #int $LINUX_SYSCALL		              # size of buffer read is returned in %eax, returns
                                      # number of bytes actually read or end-of-file (the number 0) 	

  ### EXIT IF WE’VE REACHED THE END ###
  cmpl $END_OF_FILE, %eax		          # check %eax for end-of-file marker
  jle end_loop			                  # if found, or on error, go to the end


continue_read_loop:
  ### CONVERT THE BLOCK TO UPPER CASE ###
  pushl $BUFFER_DATA			            # location of buffer
  pushl %eax				                  # size of buffer
  call convert_to_upper
  popl %eax				                    # restore %eax register with 
                                      # size of buffer
  addl $4, %esp			                  # restore %esp

  ### WRITE THE BLOCK OUT TO THE OUTPUT FILE ###
  movl %eax, %edx			                # size of buffer
  movl $SYS_WRITE, %eax			          # issue a write system call
  movl ST_FD_OUT(%ebp), %ebx		      # file to write into
  movl $BUFFER_DATA, %ecx		          # location of buffer 
  #int $LINUX_SYSCALL

  ### CONTINUE THE LOOP ###
  jmp read_loop_begin


end_loop:
### CLOSE THE FILES ###
movl $SYS_CLOSE, %eax		              # sets up a close system call,
movl ST_FD_OUT(%ebp), %ebx	          # which takes in the file descriptor 
				                              # to close
#int $LINUX_SYSCALL		                # executes system call

movl $SYS_CLOSE, %eax		              # sets up a close system call,
movl ST_FD_IN(%ebp), %ebx	            # which takes in the file descriptor 
				                              # to close
#int $LINUX_SYSCALL		                # executes system call

### EXIT ###
movl $SYS_EXIT, %eax		              # sets up an exit system call
movl $0, %ebx			                    # exit status 0
#int $LINUX_SYSCALL		                # executes system call







### CONSTANTS ###
.equ LOWERCASE_A, 'a' 		                              # lower boundary of our search
.equ LOWERCASE_Z, 'z' 		                              # upper boundary of our search
.equ UPPER_CONVERSION, 'A' - 'a'	# 65 – 97 = -32       # subtract 32 to a lowercase ASCII
			                                                  # letter to convert it to uppercase

### STACK STUFF ###
.equ ST_BUFFER_LEN, 8		      # length of buffer
.equ ST_BUFFER, 12			      # actual buffer

convert_to_upper:
  pushl %ebp			            # save old base pointer
  movl %esp, %ebp		          # make stack pointer the base pointer


  ### SET UP VARIABLES ###
  movl ST_BUFFER(%ebp), %eax	          # move the buffer into %eax
  movl ST_BUFFER_LEN(%ebp), %ebx	      # move the buffer length into %ebx
  movl $0, %edi			                    # load zero into %edi to iterate 
                                        # through each byte of the buffer

  cmpl $0, %ebx			            # sanity check: if buffer with 
                                # zero length was given, 
  je end_convert_loop		        # just leave

convert_loop:
  movb (%eax,%edi,1), %cl		      # get current byte by starting at %eax
                                  # and go %edi bytes forward, take that
                                  # value and put it in %cl

  # check if ‘a’ ≤ value ≤ ‘z’	
  cmpb $LOWERCASE_A, %cl		      # smaller than ‘a’ isn’t lowercase
  jl next_byte			              # so jump to next byte
  cmpb $LOWERCASE_Z, %cl		      # greater than ‘z’ isn’t lowercase
  jg next_byte			              # so jump to next byte

  # otherwise convert byte to uppercase
  addb $UPPER_CONVERSION, %cl	    # add -32 to %cl 	
  movb %cl, (%eax,%edi,1)		      # and store it back

next_byte:
  incl %edi			              # next byte
  cmpl %edi, %ebx		          # are we at the end of the buffer?
  jne convert_loop		        # if not at the end, convert next value

  end_convert_loop:			      # if at the end, finish (label not really necessary)

  movl %ebp, %esp		          # restore stack pointer
  popl %ebp			              # restore base pointer
  ret				                  # popl %eip



