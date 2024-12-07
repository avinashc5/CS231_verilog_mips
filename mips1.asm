.data
	n: .word 12
.text

main:
	lw $a0, n # The number you want factorial of
	jal factorial
	li $v0, 1 # Loading $v0 with 1 so that syscall will print the integer value in $a0
	add $a0, $v1, $zero # $a0 is the register whose value is printed by syscall
	syscall # For printing the result of factorial
	li $v0, 10 # Loading $v0 with 10 means that syscall will now terminate the program
	syscall # Terminates the program because $v0 is 10
	
factorial:
	addi $sp, $sp, -8 # For storing $ra and $a0 that were given as parameters to factorial in the stack 
	sw $ra, 0($sp) 
	sw $a0, 4($sp)
	beq $a0, $zero, RTN1 # fact(0) = 1. So transfer the control to RTN1
	addi $a0, $a0, -1 # The value for which the factorial should be calculated
	jal factorial # fact(n-1). It stores the value into $v1
	lw $ra, 0($sp)
	lw $a0, 4($sp) # The original parameter of whom the factorial was supposed to be calculated
	mul $v1, $a0, $v1 # fact(n) = n * fact(n-1). $v1 is the return register
	addi $sp, $sp, 8
	jr $ra
	
RTN1: # Returns 1
	li $v1, 1 # Load the return value 
	lw $ra, 0($sp) # This is a required step
	lw $a0, 4($sp)
	addi $sp, $sp, 8 # The stored values have been removed from the stack now. Pop out the removed values from the stack
	jr $ra