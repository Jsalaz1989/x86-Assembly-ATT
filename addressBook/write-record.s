  .include "linux.s"
  .include "record-def.s"

  #STACK LOCAL VARIABLES
  .equ ST_WRITE_BUFFER, 8
  .equ ST_FILEDES, 12

  .section .text

  .globl write_record
  .type write_record, @function
write_record:
  pushl %ebp			# save old base pointer
  movl %esp, %ebp		# make stack pointer the base pointer

  pushl %ebx
  movl $SYS_WRITE, %eax
  movl ST_FILEDES(%ebp), %ebx
  movl ST_WRITE_BUFFER(%ebp), %ecx
  movl $RECORD_SIZE, %edx
  int $LINUX_SYSCALL		# execute system call,
				# sys_write returns # bytes written in %eax
				# which is returned to the calling program

  popl %ebx				

  movl %ebp, %esp		# restore stack pointer	
  popl %ebp			# restore base pointer
  ret				# pop %eip
