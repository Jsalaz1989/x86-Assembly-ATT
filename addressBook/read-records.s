	.include "linux.s"
	.include "record-def.s"

	.section .data

file_name:
	.ascii "test.dat\0"			# name of file we will read from

	.section .bss
	.lcomm record_buffer, RECORD_SIZE		# buffer as big as address book		

	.section .text

	# Main program
	.globl _start
_start:
	# Stack positions of input and output descriptors
	.equ ST_INPUT_DESCRIPTOR, -4
	.equ ST_OUTPUT_DESCRIPTOR, -8

	movl %esp, %ebp			# save stack pointer
	subl $8, %esp			# allocate space to hold file descriptor

	# Open the file
	movl $SYS_OPEN, %eax		# prepare syscall 5 
	movl $file_name, %ebx		# move file name into %ebx
	movl $0, %ecx 				# open in read-only mode
	movl $0666, %edx		
	int $LINUX_SYSCALL			# execute system call,
								# sys_open returns file descriptor in %eax

	movl %eax, ST_INPUT_DESCRIPTOR(%ebp)		# store the input file 
												# descriptor away

	movl $STDOUT, ST_OUTPUT_DESCRIPTOR(%ebp)	# store the output file
												# descriptor away

record_read_loop:
	pushl ST_INPUT_DESCRIPTOR(%ebp)
	pushl $record_buffer
	call read_record
	addl $8, %esp

	# Returns the number of bytes read
	cmpl $RECORD_SIZE, %eax			# if different from requested number,
	jne finished_reading			# it’s EOF or error, so quit

	pushl $RECORD_FIRSTNAME + record_buffer		# otherwise, print first name,
	call count_chars							# but first find out its size
	addl $4, %esp

	movl %eax, %edx
	movl $SYS_WRITE, %eax
	movl ST_OUTPUT_DESCRIPTOR(%ebp), %ebx
	movl $RECORD_FIRSTNAME + record_buffer, %ecx
	int $LINUX_SYSCALL				# execute system call,
									# sys_write returns # bytes written in %eax

	pushl ST_OUTPUT_DESCRIPTOR(%ebp)
	call write_newline
	addl $4, %esp

	jmp record_read_loop

finished_reading:
	movl $SYS_EXIT, %eax
	movl $0, %ebx
	int $LINUX_SYSCALL		# execute system call,
							# sys_exit doesn’t return anything in %eax
