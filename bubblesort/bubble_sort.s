.data
	a: .word 4, 1, 5, 3, 4, 3, 1, 5, 3
	n: .word 9
.text

j main

BUBBLE_SORT:
	addi $s0, $a1, -1

# Conditions for the first for loop (i >= 0)
FOR_LOOP1_COND:
	# $t0 = 0 < i
	slt $t0, $zero, $s0
	# $t1 = 0 == i
	seq $t1, $zero, $s0
	# $t0 = i >= 0
	or $t0, $t0, $t1
	# if (i < 0) exit
	beq $t0, $zero, EXIT1

FOR_LOOP1:
	# $s1 = j = 0
	addi $s1, $zero, 0

FOR_LOOP2_COND:
	# $t0 = j < i
	slt $t0, $s1, $s0
	# if (j >= i) exit
	beq $t0, $zero, EXIT2

FOR_LOOP2:
	# $t0 = j*4
	sll $t0, $s1, 2
	# $t0 = a + j
	add $t0, $t0, $a0
	# $s2 = a[j]
	lw $s2, 0($t0)

	# $t1 = 4*(j+1)
	addi $t1, $t0, 4
	# $s3 = a[j+1]
	lw $s3, 0($t1)

	slt $t2, $s3, $s2
	beq $t2, $zero, INCREMENT_J

SWAP:
	# a[j] = $s3		store a[j+1] into a[j] address
	sw $s3, 0($t0)
	# a[j+1] = $s2		store a[j] into a[j+1] address
	sw $s2, 0($t1)

INCREMENT_J:
	addi $s1, $s1, 1
	j FOR_LOOP2_COND

EXIT2:

INCREMENT_I:
	addi $s0, $s0, -1
	j FOR_LOOP1_COND

EXIT1:
	jr $ra

main:
	# Loading the values of a and n
	la $a0, a
	lw $a1, n

	# Sort it
	jal BUBBLE_SORT
	
	addi $v0, $zero, 10
	syscall
