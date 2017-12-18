    .section .data

firststring:		# the “format string” (1st parameter) tells printf the number and type of paramenters
    .ascii “Hello! %s is a %s who loves the number %d\n\0”
name:
    .ascii "Jonathan\0"
personstring:
    .ascii "person\0"
numberloved:
    .long 3	# could have been an .equ, but decided to give it memory location	

    .section .text
    .globl _start
_start:
    # Parameters are passed in reverse order than listed in the function’s prototype
    pushl numberloved 		    # this is the %d
    pushl $personstring 		# this is the second %s
    pushl $name 		        # this is the first %s
    pushl $firststring 		    # this is the format string in the prototype

    call printf

    pushl $0
    call exit
