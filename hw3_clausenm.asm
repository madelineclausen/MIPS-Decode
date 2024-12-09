# Madeline Clausen
# clausenm
.data
recursive_find_string: .asciiz "findMajority( "
single_find_string: .asciiz "findSingleValue(  "
comma_string: .asciiz ", "
rparen_string: .asciiz " )\n"
return_string: .asciiz "return: "
candidate_string: .asciiz "candidate: "
newline: .asciiz "\n"

.text
### Part 1 Functions ###
decodeBacon:
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp) # text
    sw $s1, 8($sp) # secretMessage
    sw $s2, 12($sp) # upperChar
    sw $s3, 16($sp) # lowerChar
    sw $s5, 20($sp) # counter
    move $s0, $a0
    move $s1, $a1
    li $s2, 'A' 
    li $s3, 'B'
    li $s5, 0
    move $t1, $s0
    move $t2, $s0
loopDecodeBacon:    
    lb $t0, 0($t1) 
    beqz $t0, splitBaconPreLoop
    blt $t0, 65, nextCharacter
    blt $t0, 91, uppercase
    blt $t0, 97, nextCharacter
    blt $t0, 123, lowercase
nextCharacter:
    addi $t1, $t1, 1
    j loopDecodeBacon
uppercase:
    sb $s2, 0($t2)
    addi $t2, $t2, 1
    j nextCharacter
lowercase:
    sb $s3, 0($t2)
    addi $t2, $t2, 1
    j nextCharacter
splitBaconPreLoop:
    li $t0, 0
    sb $t0, 0($t2)
splitBaconLoop:
    lb $t0, 0($s0)
    beq $t0, 0, returnDecodeBacon0
    move $a0, $s0
    move $a1, $s2
    move $a2, $s3
    jal fromBacon    
    beq $v0, 0xFF, returnDecodeBaconNeg1
    beq $v0, 0x00, returnDecodeBacon1
    sb $v0, 0($s1)
    addi $s1, $s1, 1
    addi $s0, $s0, 5
    j splitBaconLoop
returnDecodeBacon1:
    li $t0, '\0'
    sb $t0, 0($s1)
    li $v0, 1
    j returnDecodeBacon
returnDecodeBacon0:
    li $t0, '\0'
    sb $t0, 0($s1)
    li $v0, 0
    j returnDecodeBacon
returnDecodeBaconNeg1:
    li $v0, -1
returnDecodeBacon:
    lw $ra, 0($sp)
    lw $s0, 4($sp) # text
    lw $s1, 8($sp) # secretMessage
    lw $s2, 12($sp) # upperChar
    lw $s3, 16($sp) # lowerChar
    lw $s5, 20($sp) # counter
    addi $sp, $sp, 24
    jr $ra

createBacon:
    addi $sp, $sp, -28
    sw $ra, 0($sp)
    sw $s0, 4($sp) # secretMessage
    sw $s1, 8($sp) # pattern
    sw $s2, 12($sp) # upperChar
    sw $s3, 16($sp) # lowerChar
    sw $s4, 20($sp) # multipleOf5
    sw $s5, 24($sp) # null byte
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3
    beq $s2, $s3, returnError
    li $s4, 0
baconianLoop:
    lb $s5, 0($s0)
    move $a0, $s5
    add $a1, $s4, $s1
    move $a2, $s2
    move $a3, $s3
    jal toBacon
    addi $s0, $s0, 1
    beq $v0, -1, baconianLoop
    addi $s4, $s4, 5
    beqz $s5, returnLength
    j baconianLoop
returnLength:
    move $a0, $s1
    move $v0, $s4
    j returnCreateBacon
returnError:
    li $v0, -1
returnCreateBacon:
    lw $ra, 0($sp)
    lw $s0, 4($sp) # secretMessage
    lw $s1, 8($sp) # pattern
    lw $s2, 12($sp) # upperChar
    lw $s3, 16($sp) # lowerChar
    lw $s4, 20($sp) # multipleOf5
    lw $s5, 24($sp) # null byte
    addi $sp, $sp, 28
    jr $ra
    
encodeBacon:
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp) # text
    sw $s1, 8($sp) # secretMessage
    sw $s2, 12($sp) # length*5
    sw $s3, 16($sp) # temp
    sw $s4, 20($sp) # temp 2
    move $s0, $a0
    move $s1, $a1
    move $a0, $s0
    jal length
    beqz $v0, returnEncodeError
    move $a0, $s1
    jal length
    beqz $v0, returnEncodeError
    move $t0, $s1
    move $t7, $s1
removeCharLoop:
    lb $t1, 0($s1)
    beqz $t1, moreEncodeBacon
    blt $t1, 65, increaseRead
    bgt $t1, 122, increaseRead
    bgt $t1, 90, checkBeforeIncrease
    j increaseWrite
checkBeforeIncrease:
    blt $t1, 97, increaseRead
increaseWrite:
    sb $t1, ($t0)
    addi $t0, $t0, 1
increaseRead:
    addi $s1, $s1, 1
    j removeCharLoop
moreEncodeBacon:
    sb $zero, 0($t0)
    move $a0, $t7
    jal length
    li $t0, 5
    addi $v0, $v0, 1
    mul $s2, $v0, $t0
    move $s4, $s2 
    li $t0, 4
    div $s2, $t0
    mflo $s2
    mul $s2, $s2, $t0
    add $s2, $s2, $t0
    sub $sp, $sp, $s2
    move $a0, $t7
    move $a1, $sp
    li $a2, 'A'
    li $a3, 'B'
    jal createBacon
    li $s3, 0 # counter
encodeBaconLoop:
    beq $s4, $s3, returnFinishedLoop
    lb $t0, 0($sp)
    move $a0, $s0
    beq $t0, 'B', rest_of_encode
    li $a1, 1
    j setcase_encode
rest_of_encode:
    li $a1, 0
setcase_encode:
    jal setCase
    addi $s0, $s0, 1
    beq $v0, -1, encodeBaconLoop
    addi $sp, $sp, 1
    addi $s3, $s3, 1
    j encodeBaconLoop
returnEncodeError:
    li $v0, -1
    li $v1, -1
    j returnEncodeBacon
returnFinishedLoop:
    lb $t0, 0($s0)
    beqz $t0, returnRestEncode
    move $a0, $s0
    li $a1, 0
    jal setCase
    addi $s0, $s0, 1
    j returnFinishedLoop
returnRestEncode: 
    sub $s4, $s2, $s4
    add $sp, $sp, $s4  
    li $t0, 5
    div $s2, $t0
    mflo $v1
    li $v0, 0
returnEncodeBacon:
    lw $ra, 0($sp)
    lw $s0, 4($sp) # text
    lw $s1, 8($sp) # secretMessage
    lw $s2, 12($sp) # length*5
    lw $s3, 16($sp) # temp
    lw $s4, 20($sp) # temp 2
    addi $sp, $sp, 24   
    jr $ra
    

### Part 2 Functions ###

findMajority:
    # prologue
    addi $sp, $sp, -32
    sw $ra, 0($sp)
    sw $s0, 4($sp) # array
    sw $s1, 8($sp) # candidate
    sw $s2, 12($sp) # start_index
    sw $s3, 16($sp) # end index
    sw $s4, 20($sp) # mid
    sw $s5, 24($sp) # LHS
    sw $s6, 28($sp) # RHS
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3
    # main
    sub $t0, $s3, $s2
    addi $t0, $t0, 1 # array_length
    li $v0, 4 # print findMajority()
    la $a0, recursive_find_string
    syscall
    li $v0, 1
    move $a0, $s2
    syscall
    li $v0, 4
    la $a0, comma_string
    syscall
    li $v0, 1
    move $a0, $s3
    syscall
    li $v0, 4
    la $a0, rparen_string
    syscall
    bne $t0, 1, recursive_else
    sll $t1, $s2, 2
    add $t1, $t1, $s0 # array[start_index]
    lw $t1, 0($t1)
    bne $t1, $s1, inner_else
    li $v0, 4 # return 1
    la $a0, return_string
    syscall
    li $v0, 1
    li $a0, 1
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $v0, 1
    j epilogue
inner_else:
    li $v0, 4 # return 0
    la $a0, return_string
    syscall
    li $v0, 1
    li $a0, 0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    li $v0, 0
    j epilogue
recursive_else:
    li $s4, 2
    div $t0, $s4
    mflo $s4 # mid
    add $t0, $s4, $s2
    addi $t0, $t0, -1 # (start_index + mid - 1)
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    move $a3, $t0
    jal findMajority
    move $s5, $v0 # LHS_sum
    move $a0, $s0
    move $a1, $s1
    add $a2, $s4, $s2
    move $a3, $s3
    jal findMajority
    move $s6, $v0 # RHS_sum
    li $v0, 4
    la $a0, return_string
    syscall
    li $v0, 1
    add $a0, $s5, $s6
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    add $v0, $s5, $s6
epilogue:
    lw $ra, 0($sp)
    lw $s0, 4($sp) # array
    lw $s1, 8($sp) # candidate
    lw $s2, 12($sp) # start_index
    lw $s3, 16($sp) # end index
    lw $s4, 20($sp) # mid
    lw $s5, 24($sp) # LHS
    lw $s6, 28($sp) # RHS
    addi $sp, $sp, 32
    jr $ra

iterateCandidates:
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp) # inputArray
    sw $s1, 8($sp) # size
    sw $s2, 12($sp) # inputArray[i]
    sw $s3, 16($sp) # i
    move $s0, $a0
    move $s1, $a1
    bltz $s1, justReturn
    li $s3, 0 # i
candidateForLoop:
    beq $s3, $s1, justReturn
    sll $s2, $s3, 2
    add $s2, $s2, $s0
    lw $s2, 0($s2)
    li $v0, 4
    la $a0, candidate_string
    syscall
    li $v0, 1
    move $a0, $s2
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    move $a0, $s0
    move $a1, $s2
    li $a2, 0
    move $a3, $s1
    jal findMajority
    move $t2, $v0 # candidate_sum
    addi $t3, $s1, 1
    li $t4, 2
    div $t3, $t4
    mflo $t3 # ((size + 1) / 2))
    bge $t2, $t3, finalJustReturn
    addi $s3, $s3, 1
    j candidateForLoop
justReturn:
    li $v0, -1
    j ICepilogue
finalJustReturn:
    move $v0, $s2
ICepilogue:
    lw $ra, 0($sp)
    lw $s0, 4($sp) # inputArray
    lw $s1, 8($sp) # size
    lw $s2, 12($sp) # inputArray[i]
    lw $s3, 16($sp) # i
    addi $sp, $sp, 20
    jr $ra


### Part 3 Functions ###

itof:
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp) # integerValue
    sw $s1, 8($sp) # fd
    sw $s2, 12($sp) # number_of_digits
    sw $s3, 16($sp) # flag
    move $s0, $a0
    move $s1, $a1
    li $s2, 0
    bgez $s0, itOfLoop
    li $s3, 0
    li $t0, -1
    mul $s0, $s0, $t0
itOfLoop:
    blez $s0, negFlagCheck
    li $t1, 10
    div $s0, $t1
    mflo $s0
    mfhi $t2
    addi $sp, $sp, -1
    addi $t2, $t2, 48
    sb $t2, 0($sp)
    addi $s2, $s2, 1
    j itOfLoop
negFlagCheck:
    li $t0, 0
    bnez $s3, itOfLoop2
    addi $sp, $sp, -1
    li $t1, 45
    sb $t1, 0($sp)
    addi $s2, $s2, 1
itOfLoop2:
    beq $t0, $s2, returnItOf
    move $a0, $s1
    move $a1, $sp
    li $a2, 1
    li $v0, 15
    syscall
    addi $sp, $sp, 1
    addi $t0, $t0, 1
    j itOfLoop2
returnItOf:
    lw $ra, 0($sp)
    lw $s0, 4($sp) # integerValue
    lw $s1, 8($sp) # fd
    lw $s2, 12($sp) # number_of_digits
    lw $s3, 16($sp) # flag
    addi $sp, $sp, 20
    jr $ra

findSingleValue:
    addi $sp, $sp, -36
    sw $ra, 0($sp)
    sw $s0, 4($sp) # inputArray
    sw $s1, 8($sp) # startIndex
    sw $s2, 12($sp) # endIndex
    sw $s3, 16($sp) # fd
    sw $s4, 20($sp) # array_length
    sw $s5, 24($sp) # ret
    sw $s6, 28($sp) # mid
    sw $s7, 32($sp) # target
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3
    move $a0, $s3 # write to file
    la $a1, single_find_string
    li $a2, 17
    li $v0, 15
    syscall
    move $a0, $s1
    move $a1, $s3
    jal itof
    
    move $a0, $s3 # write to file
    la $a1, comma_string
    li $a2, 2
    li $v0, 15
    syscall
    move $a0, $s2
    move $a1, $s3
    jal itof
    move $a0, $s3 # write to file
    la $a1, rparen_string
    li $a2, 3
    li $v0, 15
    syscall
    sub $s4, $s2, $s1
    addi $s4, $s4, 1 # array_length
    li $t0, 2
    div $s4, $t0
    mfhi $t0
    bnez $t0, mainElse
    li $s5, -1 # ret
    move $a0, $s3 # write to file
    la $a1, return_string
    li $a2, 8
    li $v0, 15
    syscall
    move $a0, $s5
    move $a1, $s3
    jal itof
    move $a0, $s3 # write to file
    la $a1, newline
    li $a2, 1
    li $v0, 15
    syscall
    move $v0, $s5
    j returnSingleValue
mainElse:
    bne $s4, 1, innerSingleElse
    li $t0, 4
    mul $t0, $t0, $s1
    add $s5, $s0, $t0
    move $a0, $s3 # write to file
    la $a1, rparen_string
    li $a2, 8
    li $v0, 15
    syscall
    move $a0, $s5
    move $a1, $s3
    jal itof
    move $a0, $s3 # write to file
    la $a1, newline
    li $a2, 1
    li $v0, 15
    syscall
    move $v0, $s5
    j returnSingleValue
innerSingleElse:
    li $t0, 2
    div $s4, $t0
    mflo $s6 # mid
    add $s7, $s6, $s1
    sll $s7, $s7, 2
    add $s7, $s7, $s0 # target
    addi $t0, $s7, -4 # left
    addi $t1, $s7, 4 # right
    bne $s7, $t0, targetNotLeft
    bne $s7, $t1, targetLeftNotRight
    j remainingInnerElse
targetNotLeft:
    beq $s7, $t1, targetNotLeftRight
    move $a0, $s3 # write to file
    la $a1, return_string
    li $a2, 8
    li $v0, 15
    syscall
    move $a0, $s7
    move $a1, $s3
    jal itof
    move $a0, $s3 # write to file
    la $a1, newline
    li $a2, 1
    li $v0, 15
    syscall
    move $v0, $s7
    j returnSingleValue
targetNotLeftRight:
    addi $t0, $s6, 3
    sub $t0, $s2, $t0
    li $t1, 2
    div $t0, $t1
    mfhi $t0 # (endIndex - (mid + 2) + 1) mod 2
    bnez $t0, targetNotLeftRightElse
    move $a0, $s0
    move $a1, $s1
    add $a2, $s1, $s6
    addi $a2, $a2, -1
    move $a3, $s3
    jal findSingleValue
    move $s5, $v0
    j remainingInnerElse
targetNotLeftRightElse:
    move $a0, $s0
    add $a1, $s1, $s6
    addi $a1, $a1, 2
    move $a2, $s2
    move $a3, $s3
    jal findSingleValue
    move $s5, $v0
    j remainingInnerElse
targetLeftNotRight:
    addi $t0, $s6, -1
    sub $t0, $t0, $s1
    li $t1, 2
    div $t0, $t1
    mfhi $t0 # ((mid - 2) - startIndex + 1) mod 2
    bnez $t0, targetLeftNotRightElse
    move $a0, $s0
    add $a1, $s1, $s6
    addi $a1, $a1, 1
    move $a2, $s2
    move $a3, $s3
    jal findSingleValue
    move $s5, $v0
    j remainingInnerElse
targetLeftNotRightElse:
    move $a0, $s0
    move $a1, $s1
    add $a2, $s1, $s6
    addi $a2, $a2, -2
    move $a3, $s3
    jal findSingleValue
    move $s5, $v0
    j remainingInnerElse
remainingInnerElse:
    move $a0, $s3 # write to file
    la $a1, return_string
    li $a2, 8
    li $v0, 15
    syscall
    move $a0, $s5
    move $a1, $s3
    jal itof
    move $a0, $s3 # write to file
    la $a1, newline
    li $a2, 1
    li $v0, 15
    syscall
    move $v0, $s5
returnSingleValue:
    lw $ra, 0($sp)
    lw $s0, 4($sp) # inputArray
    lw $s1, 8($sp) # startIndex
    lw $s2, 12($sp) # endIndex
    lw $s3, 16($sp) # fd
    lw $s4, 20($sp) # array_length
    lw $s5, 24($sp) # ret
    lw $s6, 28($sp) # mid
    lw $s7, 32($sp) # target
    addi $sp, $sp, 36
    jr $ra
