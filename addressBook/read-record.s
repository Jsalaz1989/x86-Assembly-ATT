.include "linux.s"
.include "record-def.s"

#STACK LOCAL VARIABLES
.equ ST_READ_BUFFER, 8
.equ ST_FILEDES, 12

.section .text

.globl read_record
.type read_record, @function
read_record:
pushl %ebp		 	# save old base pointer
movl %esp, %ebp		# make stack pointer the base pointer

pushl %ebx
movl $SYS_READ, %eax
movl ST_FILEDES(%ebp), %ebx
movl ST_READ_BUFFER(%ebp), %ecx
movl $RECORD_SIZE, %edx
int $LINUX_SYSCALL		# execute system call,
				# sys_read returns number of bytes read in %eax,
				# which is returned to the calling program


popl %ebx

movl %ebp, %esp		# restore stack pointer
popl %ebp			# restore base pointer
ret				# pop %eip
