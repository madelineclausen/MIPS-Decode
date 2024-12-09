.include "hw3_clausenm.asm"
.include "hw3_helpers.asm"
.globl main

# Data Section
.data

# PART 2
array: .word 17, 13, 17, 17, 22, 44, 73
candidate: .word 17
startIndex: .word 0
endIndex: .word 8
inputArray: .word 10, 10, 15, 15, 20, 20, 25, 25, 30, 30
size: .word 7
fd: .word 0
file_name: .asciiz "mips_test.txt"
findMajorityString: .asciiz "Return value was: "
secretMessageString: .asciiz "Pattern is: "
#text: .asciiz "WhENeveR stUDeNts PrOGrAM LoVeLy CodE veRY  lAte AT nigHt, my bRAIN ExpLoDES! *SIgh sigh sigh*"
#secretMessage: .asciiz "xxxxxxxxxxxxxxxxxxx"
pattern: .asciiz "Computer Science is awesome!Computer Science is awesome!Computer Science is awesome!Computer Science is awesome!"
upperSym: .asciiz "3"
lowerSym: .asciiz "q"
text: .asciiz "Spread love everywhere you go."
secretMessage: .asciiz "way2go"
endline: .asciiz "\n"
part3_array: .word 10, 10, 15, 20, 20, 25, 25, 30, 30

# Program 
.text
main:

  # encodeBacon
    #la $a0, text
    #la $a1, secretMessage
    #jal encodeBacon
    
  # print label
    #move $a0, $v1
    #li $v0, 1
    #syscall
    
  # print newline
    #la $a0, endline
    #li $v0, 4
    #syscall
    
  # print label
    #la $a0, text
    #li $v0, 4
    #syscall
    
  # findSingleValue
    la $a0, file_name
    li $a1, 1
    li $a2, 0
    li $v0, 13
    syscall
    addi $sp, $sp, -4
    sw $s0, 0($sp)
    move $s0, $v0
    move $a0, $v0
    la $a1, upperSym
    li $a2, 1
    li $v0, 15
    syscall
    #part3_array
    la $a0, part3_array
    li $a1, 0
    li $a2, 7
    move $a3, $s0
    jal findSingleValue
    move $t0, $v0
    li $v0, 16
    move $a0, $s0
    syscall
    lw $s0, 0($sp)
    addi $sp, $sp, 4

    # save the return value
    #move $t0, $v0  
    #move $t1, $v1
    
    #print newline
    #la $a0, endline
    #li $v0, 4
    #syscall 

    #print label
    #la $a0, findMajorityString
    #li $v0, 4
    #syscall

    #quit program
    li $v0, 10
    syscall
    