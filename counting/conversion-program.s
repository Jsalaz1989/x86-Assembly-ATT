    .include "linux.s"

    .section .data

    # This is where it will be stored
    tmp_buffer:
    .ascii "\0\0\0\0\0\0\0\0\0\0\0“		# 11 null bytes

    .section .text

    .globl _start

_start:
    movl %esp, %ebp

    pushl $tmp_buffer		# storage for the result

    pushl $824		        # number to convert

    call integer2string
    addl $8, %esp

    pushl $tmp_buffer		# get the character count for our system call

    call count_chars
    addl $4, %esp

    movl %eax, %edx # the count goes in %edx for SYS_WRITE

    # Make the system call
    movl $SYS_WRITE, %eax
    movl $STDOUT, %ebx
    movl $tmp_buffer, %ecx
    int $LINUX_SYSCALL

    # Write a carriage return
    pushl $STDOUT
    call write_newline

    # Exit
    movl $SYS_EXIT, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL

