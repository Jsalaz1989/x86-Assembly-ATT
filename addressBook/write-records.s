  .include "linux.s"
  .include "record-def.s"

  .section .data

  # Data of the records we want to write

record1:
  .ascii "Fredrick\0" 			# converts string into byte data
  .rept 31 				# padding to 40 bytes 
  .byte 0				# inserts a 0 at the end of the field
  .endr

  .ascii "Bartlett\0"			# converts string into byte data
  .rept 31 				# padding to 40 bytes
  .byte 0				# inserts a 0 at the end of the field
  .endr

  .ascii "4242 S Prairie\nTulsa, OK 55555\0" 	# converts string into byte data
  .rept 209 				# padding to 240 bytes
  .byte 0				# inserts a 0 at the end of the field
  .endr

  .long 45				# age of this contact = 45
					# long is already 4 bytes					
record2:
  .ascii "Marilyn\0"
  .rept 32 #Padding to 40 bytes
  .byte 0
  .endr

  .ascii "Taylor\0"
  .rept 33 #Padding to 40 bytes
  .byte 0
  .endr

  .ascii "2224 S Johannan St\nChicago, IL 12345\0"
  .rept 203 #Padding to 240 bytes
  .byte 0
  .endr

  .long 29

record3:
  .ascii "Derrick\0"
  .rept 32 #Padding to 40 bytes
  .byte 0
  .endr

  .ascii "McIntire\0"
  .rept 31 #Padding to 40 bytes
  .byte 0
  .endr

  .ascii "500 W Oakland\nSan Diego, CA 54321\0"
  .rept 206 #Padding to 240 bytes
  .byte 0
  .endr

  .long 36

file_name:
  .ascii "test.dat\0 " 		# name of file we will write to

  .equ ST_FILE_DESCRIPTOR, -4	# position on stack of its file descriptor

  .globl _start
_start:
  movl %esp, %ebp		# save stack pointer
  subl $4, %esp			# allocate space to hold file descriptor

  # Open the file
  movl $SYS_OPEN, %eax		# prepare syscall 5 
  movl $file_name, %ebx		# move file name into %ebx
  movl $0101, %ecx 		# open in write-only mode
  movl $0666, %edx		# and create if doesn’t exist
  int $LINUX_SYSCALL		# execute system call,
				# sys_open returns file descriptor in %eax

  movl %eax, ST_FILE_DESCRIPTOR(%ebp)	# store the file descriptor away


  # Write the first record
  pushl ST_FILE_DESCRIPTOR(%ebp)
  pushl $record1
  call write_record
  addl $8, %esp

  # Write the second record
  pushl ST_FILE_DESCRIPTOR(%ebp)
  pushl $record2
  call write_record
  addl $8, %esp

  # Write the third record
  pushl ST_FILE_DESCRIPTOR(%ebp)
  pushl $record3
  call write_record
  addl $8, %esp

  # Close the file descriptor
  movl $SYS_CLOSE, %eax
  movl ST_FILE_DESCRIPTOR(%ebp), %ebx
  int $LINUX_SYSCALL		# execute system call,
				# sys_close returns 0 in %eax
  # Exit the program
  movl $SYS_EXIT, %eax
  movl $0, %ebx
  int $LINUX_SYSCALL		# execute system call,
				# sys_exit doesn’t return anything in %eax

