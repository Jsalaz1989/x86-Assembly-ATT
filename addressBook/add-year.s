	.include "linux.s"
	.include "record-def.s"

	.section .data

input_file_name:
	.ascii "test.dat\0"

output_file_name:
	.ascii "testout.dat\0"

	.section .bss
	.lcomm record_buffer, RECORD_SIZE

	# Stack offsets of local variables
	.equ ST_INPUT_DESCRIPTOR, -4
	.equ ST_OUTPUT_DESCRIPTOR, -8


	.section .text
	.globl _start
_start:
	movl %esp, %ebp			# save stack pointer
	subl $8, %esp			# allocate space for local variables

	# Open file for reading
	movl $SYS_OPEN, %eax				# prepare syscall 5 
	movl $input_file_name, %ebx			# move input file name into %ebx
	movl $0, %ecx						# open in read-only mode
	movl $0666, %edx		
	int $LINUX_SYSCALL					# execute system call,
										# sys_open returns file descriptor in %eax

	movl %eax, ST_INPUT_DESCRIPTOR(%ebp)	 # store the input file descriptor away

	# Open file for writing
	movl $SYS_OPEN, %eax				# prepare syscall 5 
	movl $output_file_name, %ebx		# move output file name into %ebx
	movl $0101, %ecx 					# open in write-only mode
	movl $0666, %edx					# and create if doesn’t exist
	int $LINUX_SYSCALL					# execute system call,
										# sys_open returns file descriptor in %eax

	movl %eax, ST_OUTPUT_DESCRIPTOR(%ebp)	 # store the output file descriptor away

loop_begin:
	pushl ST_INPUT_DESCRIPTOR(%ebp)
	pushl $record_buffer
	call read_record
	addl $8, %esp

	# Returns the number of bytes read
	cmpl $RECORD_SIZE, %eax			# if different from requested number,
	jne loop_end					# it’s EOF or error, so quit

	incl record_buffer + RECORD_AGE		# increment the age

	# Write the record out
	pushl ST_OUTPUT_DESCRIPTOR(%ebp)
	pushl $record_buffer
	call write_record
	addl $8, %esp

	jmp loop_begin

loop_end:
	movl $SYS_EXIT, %eax
	movl $0, %ebx
	int $LINUX_SYSCALL			# execute system call,
								# sys_exit doesn’t return anything in %eax
	
