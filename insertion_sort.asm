.data
	arr: .word 2, 3, 1, 5, 4
	n: .word 5
.text

MAIN:
	la $a2, arr
	lw $a1, n
	jal INSERT_SORT
	
	jal PRINTARRAY
	
	li $v0, 10
	syscall
# -----------------------------Insertion Sort start--------------------------------#
INSERT_SORT:
	addi $s0, $zero, 1 # $s0 = i = 1
	
	#----------------------For loop start-------------------------#
FOR_LOOP:
	slt $t0, $s0, $a1
	bne $t0, 1, EXIT
	sll $t0, $s0, 2
	add $t0, $a2, $t0
	lw $s1, 0($t0) # $s1 = key = arr[i]
	addi $s2, $s0, -1 # $s2 = j = i - 1
	
		#-------------While loop start--------------#
WHILE_CONDITIONS:
	slt $t0, $zero, $s2
	beq $t0, 0, WHILE_EXIT
	sll $t0, $s2, 2
	add $t0, $a2, $t0
	lw $s3, 0($t0)
	slt $t0, $s1, $s3
	beq $t0, 0, WHILE_EXIT
	
WHILE_LOOP:
	sll $t0, $s2, 2
	add $t0, $t0, $a2
	lw $s5, 0($t0)
	sw $s5, 4($t0)
	addi $s2, $s2, -1
	j WHILE_CONDITIONS	
	
WHILE_EXIT:
	sll $t0, $s2, 2
	add $t0, $t0, $a2
	sw $s1, 4($t0)
	addi $s0, $s0, 1
	j FOR_LOOP
	
		#----------While loop end----------#
	
EXIT:
	jr $ra
	#------------------For loop end------------------------#
	
#--------------------------Insertion sort end-------------------------------#

PRINTARRAY:
	addi $s0, $zero, 0
	
For_loop:
	slt $t0, $s0, $a1
	beq $t0, $zero, For_exit
	
	sll $t0, $s0, 2
	add $t0, $t0, $a2
	lw $a0, 0($t0)
	li $v0, 1
	syscall
	addi $s0, $s0, 1
	j For_loop
	
For_exit:
	jr $ra