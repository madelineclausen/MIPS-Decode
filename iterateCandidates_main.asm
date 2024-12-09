.include "hw3_netid.asm"

.globl main

# Data Section
.data
input_array: .word 1, 2, 2, 4, 1, 4, 4, 4

# Program 
.text
main:

    # load the arguments
    la $a0, input_array
    li $a1, 8
    jal iterateCandidates 

    #quit program
    li $v0, 10
    syscall

