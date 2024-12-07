.data
	myMessage: .asciiz "Hello Assembly \n"
.text
	li $v0, 4
	la $a0, myMessage
	syscall

	li $v0, 10
	syscall