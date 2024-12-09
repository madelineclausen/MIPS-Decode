# TREAT THIS FILE AS A BLACK BOX. ASSUME YOU DO NOT SEE THIS CODE
.text

# $a0: Starting address of string s
length:                 
    li $v0,0        
length_nextCh: 
    lb $t0, 0($a0)  
    beqz $t0,length_end 
    addi $v0,$v0,1  
    addi $a0,$a0,1  
    j length_nextCh        
length_end:
    jr $ra



# $a0: letter to convert to Baconian sequence
# $a1: starting address to store 5 character for baconian sequence
# $a2: character to use to represent the uppercase symbol in the pattern
# $a3: character to use to represent the lowercase symbol in the pattern
toBacon:
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)
	
	move $s0, $a0
	move $s1, $a1
	beq $a2, $a3, toBaconErr
	
	la $t2, lookupStr
	beq $s0, ' ', usespace
	beq $s0, '!', useexclamation
	beq $s0, '\'', usesquote
	beq $s0, ',', usecomma
	beq $s0, '.', usedot
	beq $s0, '\0', useeom
	bge $s0, 'a', toUppercase
	bgt $s0, 'Z', toBaconErr
	blt $s0, 'A', toBaconErr
	j usechar
toUppercase:
	bgt $s0, 'z', toBaconErr
	addi $s0, $s0, -32
usechar:	
	li $t0, 'A'
	sub $t1, $s0, $t0
	li $t3, 5
	mul $t1, $t1, $t3
	j replacePattern
usespace:
	li $t1, 130
	j replacePattern
useexclamation:
	li $t1, 135
	j replacePattern
usesquote:
	li $t1, 140
	j replacePattern
usecomma:
	li $t1, 145
	j replacePattern
usedot:
	li $t1, 150
	j replacePattern
useeom:
	li $t1, 155	
replacePattern:
	add $t1, $t1, $t2 # pattern address
	addi $t4, $t1, 5
patternLoop:
	beq $t1, $t4, patternLoopOut
	lb $t5, ($t1)
	beq $t5, 'B', useUpperSym
	sb $a3, ($s1)
	j loopNext
useUpperSym:
	sb $a2, ($s1)
loopNext:
	addi $t1, $t1, 1
	addi $s1, $s1, 1
	j patternLoop
patternLoopOut:
	li $v0, 0
	j patterLoopEnd
toBaconErr:
	li $v0, -1
patterLoopEnd:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra



# $a0: starting address of 5 characters for baconian sequence
# $a1: character to use to represent the uppercase symbol in the pattern
# $a2: character to use to represent the lowercase symbol in the pattern
fromBacon:
	beq $a1, $a2, fromBaconErr
	addi $sp, $sp, -5
	li $t0, 0
fromBaconConvert:
	beq $t0, 5, fromBaconConvertOut
	add $t1, $t0, $a0
	lb $t1, ($t1)
	beq $t1, $a1, addB
	beq $t1, $a2, addA
	j fromBaconErr
addB:
	li $t1, 'B'
	j storeChar
addA:
	li $t1, 'A'
storeChar:
	add $t2, $t0, $sp
	sb $t1, ($t2)
	addi $t0, $t0, 1
	j fromBaconConvert
fromBaconConvertOut:
	li $t0, 0
	la $t9, lookupStr
findloop:
	add $t1, $t0, $t9
	lb $t2, ($t1)
	lb $t3, ($sp)
	bne $t2, $t3, goNext
	lb $t2, 1($t1)
	lb $t3, 1($sp)
	bne $t2, $t3, goNext
	lb $t2, 2($t1)
	lb $t3, 2($sp)
	bne $t2, $t3, goNext
	lb $t2, 3($t1)
	lb $t3, 3($sp)
	bne $t2, $t3, goNext
	lb $t2, 4($t1)
	lb $t3, 4($sp)
	bne $t2, $t3, goNext
	# found the pattern, return
	li $t1, 5
	div $t0, $t1
	mflo $t1 # index in the lookup
	blt $t1, 26, returnChar
	beq $t1, 26, returnspace
	beq $t1, 27, returnexclamation
	beq $t1, 28, returnsquote
	beq $t1, 29, returncomma
	beq $t1, 30, returndot
	li $v0, 0x00 # EOM
	j fromBaconEnd
returnspace:
	li $v0, ' '
	j fromBaconEnd
returnexclamation:
	li $v0, '!'
	j fromBaconEnd
returnsquote:
	li $v0, '\''
	j fromBaconEnd
returncomma:
	li $v0, ','
	j fromBaconEnd
returndot:
	li $v0, '.'
	j fromBaconEnd
returnChar:
	addi $v0, $t1, 'A'
	j fromBaconEnd
goNext:
	addi $t0, $t0, 5
	j findloop	
fromBaconErr:
	li $v0, 0xFF
fromBaconEnd:
	addi $sp, $sp, 5
	jr $ra



# $a0: address of character 
# $a1: flag, 0 to convert to lowercase, 1 to convert to uppercase
setCase:
	lb $t0, ($a0)
	ble $t0, 'Z', isUpper
	ble $t0, 'z', isLower
	j notCharacter
isUpper:
	blt $t0, 'A', notCharacter
	bne $a1, 0, endCase
	# make lowercase
	addi $t0, $t0, 32
	sb $t0, ($a0)
	j endCase
isLower:
	blt $t0, 'a', notCharacter
	bne $a1, 1, endCase
	# make uppercase
	addi $t0, $t0, -32
	sb $t0, ($a0)
endCase:
	li $v0, 0
	jr $ra
notCharacter:
	li $v0, -1
	jr $ra
	
	
.data
lookupStr: .asciiz "AAAAAAAAABAAABAAAABBAABAAAABABAABBAAABBBABAAAABAABABABAABABBABBAAABBABABBBAABBBBBAAAABAAABBAABABAABBBABAABABABBABBABABBBBBAAABBAABBBABABBABBBBBAABBBABBBBBABBBBB"