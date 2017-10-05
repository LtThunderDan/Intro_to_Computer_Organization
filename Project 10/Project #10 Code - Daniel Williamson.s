.data
GRID_WIDTH:		.word		80		# need to add 1 to print as string
GRID_HEIGHT:	.word		23
GRID_SIZE:		.word		1840	# because I can't precalculate it in

RGEN:					.word		1073807359	# a sufficiently large prime for rand
POUND:				.byte		35		# the '#' character
SPACE:				.byte		32		# the ' ' character
NEWLINE:			.byte		10		# the newline character

rsdPrompt:		.asciiz "Enter a seed number (1073741824 - 2147483646): "
smErr1:				.asciiz "That number is too small, try again: "
bgErr:				.asciiz "That number is too large, try again: "
newLine:			.asciiz "\n"

grid:					.space	1841	# ((79 + 1) * 23) + 1 bytes reserved for grid
rSeed:				.word		2000000000			# a seed for generating a random number

NORTH:				.word		0
EAST:					.word   1
SOUTH:				.word		2
WEST:					.word		3

.text
.globl main

main:
	sw	$ra, 0($sp)						# save the return address
	jal	srand									# get a random seed
	jal	ResetGrid							# reset the grid to '#'s
	li	$t0, 1								# set up for start of generation at (1,1)
	sw	$t0, -4($sp)					# push first param
	sw	$t0, -8($sp) 					# push second param
	li  $t8, 160
	jal	Visit									# start the recursive generation
	la  $a0, testPrint
	li  $v0, 4
	syscall
	jal	PrintGrid							# display the grid
	lw	$ra, 0($sp)						# restore the return address
	jr	$ra										# exit the program

ResetGrid:
	# save the registers
	sw	$s0, -4($sp)					# $s0 will be the loop counter
	sw	$s1, -8($sp)					# $s1 will hold the array bound
	sw	$s2, -12($sp)					# $s2 will be the grid base address
	sw	$s3, -16($sp)					# $s3 will hold the character
	sw	$s4, -20($sp)					# $s4 will hold the grid width
	sw  $s5, -24($sp) 				# $s5 will hold the newline character
	sw	$s6, -28($sp)					# $s6 used for calculations
	# NOTICE THAT I DON'T BOTHER MOVING THE STACK POINTER

	# load the working values
	li	$s0, 1								# initialize the counter
	lw	$s1, GRID_SIZE				# initialize the array bound
	la	$s2, grid							# get the base address
	lb	$s3, POUND						# store the '#' ASCII code
	lw	$s4, GRID_WIDTH 			# store the grid width
	lb	$s5, NEWLINE					# store the newline ASCII code

ResetLoop:
	sb	$s3, 0($s2)						# put a '#' in the grid
	addi	$s0, $s0, 1					# increment the loop counter
	addi	$s2, $s2, 1					# point at next char position
	div	$s0, $s4							# divide the counter by grid width
	mfhi	$s6									# get remainder in calculation register
	bnez	$s6, NoNewLine			# keep going

	sb	$s5, 0($s2)   				# put a newline in the grid
	addi	$s0, $s0, 1					# increment the loop counter
	addi	$s2, $s2, 1					# point at next char position

NoNewLine:
	blt	$s0, $s1, ResetLoop		# if less than end, loop again

	# when we fall out of the loop, restore the registers and return
	lw	$s0, -4($sp)
	lw	$s1, -8($sp)
	lw	$s2, -12($sp)
	lw	$s3, -16($sp)
	lw	$s4, -20($sp)
	lw  $s5, -24($sp)
	lw	$s6, -28($sp)
	# IN A LANGUAGE WITH PUSH/POP, YOU WOULD HAVE TO POP THEM
	# FROM THE STACK IN THE REVERSE ORDER YOU PUSHED THEM.

	jr	$ra		# return

srand:
	# For this function, we only need to preserve 3 registers.  We use
	# $a0 and $v0 for I/0, and we use $s0 as a scratch register.

	# save the registers
	sw	$v0, -4($sp)					# $v0 will be the service code
	sw	$a0, -8($sp)					# $a0 will point to the grid string
	sw	$s0, -12($sp)					# $s0 will hold the input for testing

	# prompt for a random seed and get the value
	la	$a0, rsdPrompt
	li	$v0, 4								# print_string
	syscall

input10:
	li	$v0, 5								# read_int
	syscall
	li	$s0, 1073741823				# put 2147483646 in t0 for comparison
	bgtu	$v0, $s0, input11		# input bigger than 1073741823?
	la	$a0, smErr1						# no, point to error and
	li	$v0, 4								# print_string
	syscall
	j	input10									# try again

input11:
	li	$s0, 2147483646				# upper bound in register t0 for comparison
	bleu	$v0, $s0, input12		# less than or equal 2147483646?
	la	$a0, bgErr						# no, point to error and
	li	$v0, 4								# print_string
	syscall
	j	input10									# try again

input12:
	# number is good, save and move on
	sw	$v0, rSeed

	# restore the registers
	lw	$v0, -4($sp)
	lw	$a0, -8($sp)
	lw	$s0, -12($sp)

	jr	$ra										# return

rand:
	lw  $t0,  -8($sp)					# load low bound
	lw  $t1, -12($sp)					# load high bound
	lw $t2, RGEN							# prime number
	lw $t9, rSeed							# load user seed
  multu $t2, $t9						# seed times multiplier
  mflo $t5									# store low
	mfhi $t6
	sw   $t5, rSeed
	sub $t1, $t1, $t0
	addiu $t1, $t1, 1
	divu $t6,$t1
	mfhi $t6

  addu $t6, $t6, $t0				# add low bound and low
	sw  $t6,  -4($sp)					# move hi to sp
	jr	$ra										# return

XYToIndex:
	lw  $t0, GRID_WIDTH
	lw  $t1,  -8($sp)   	 	# X
	lw  $t2, -12($sp)  		  # Y
	mul $t2, $t2, $t0   	  # Y * GRID_WIDTH
	add $t2, $t2, $t1    		# Result + X
	sw  $t2,  -4($sp)   	  # Store the return
	jr	$ra								  # return

IsInBounds:
	lw  $t0,  -8($sp)       # x value
	lw  $t1, -12($sp)       # y value
	lw  $t2, GRID_WIDTH     # load grid width
	lw  $t3, GRID_HEIGHT		# load grid height
	addi $t2, $t2, -1
	beqz $t0, false
	beqz $t1, false
	bgtu $t0, $t2, false
	bgeu $t1, $t3, false

	li $t4, 1
	j true

false:
	li $t4, 0
	sw $s0, -8($sp)
	sw $s1, -12($sp)
	jr $ra

true:
	sw $t4, -4($sp)
	jr	$ra

Visit:
	# TO DO:  You won't need this for project 9; it is just a placeholder
	#         for project 10.
	# Using this method as a testing area
	sw   $ra, -16($sp) 					# store in sp
	la  $a0, newLine						# new line
	li  $v0, 4
	syscall


	li  $t1, 0									# min
	li  $t2, 3  								# max
	sw  $t1, -8($sp) 						# Store min
	sw  $t2, -12($sp) 					# Store max
	jal rand										# jump to method
	lw  $a0,  -4($sp)						# store return
	li  $v0, 1									# print int
	syscall											# execute
	la  $a0, newLine						# new line
	li  $v0, 4
	syscall
	lw $a0, -4($sp)
	li $t1, 0
	la $s4, grid
	lb $s3, SPACE
	lw $s0, -4($sp) # x value
	lw $s1, -8($sp) # y value
	beq $t1, $a0, north
	li $t1, 1
	beq $t1, $a0, east
	li $t1, 2
	beq $t1, $a0, south
	li $t1, 3
	beq $t1, $a0, west

#This is my north method, it essentailly stores the x and y values
#then checks to see if they are in bounds of the grid.
#next it will move the "drill" for tunneling north (-2)
#then it will remove the #'s nessacary and re-print the grid.

north:
	li $t2, 0
	li $t3, 0
	addi $s1, $s1, -1
	sw $s0, -4($sp)
	sw $s1, -8($sp)
	sw $s0, -8($sp)
	sw $s1, -12($sp)
	jal IsInBounds
	move $t7, $s1
	addi $t7, $t7, -2
	sw $s0, -8($sp)
	sw $t7, -12($sp)
	jal XYToIndex
	lb   $s7, SPACE
	lw $t0, -4($sp)
	beq $t0, $s7, Visit
	jal XYToIndex
	move $s1, $t7
	sw $s0, -8($sp)
	sw $s1, -12($sp)
	jal IsInBounds
	lw $t0, -4($sp)
	add $t0, $s4, $t0
	sb $s3, 0($t0)
	addi $t3, $t3, -1

	li $a0, 0
	li $v0, 1
	syscall
	jal PrintGrid

#This is my east method, it essentailly stores the x and y values
#then checks to see if they are in bounds of the grid.
#next it will move the "drill" for tunneling east (-2)
#then it will remove the #'s nessacary and re-print the grid.

east:
	addi $s0, $s0, 1
	sw $s0, -4($sp)
	sw $s1, -8($sp)
	sw $s0, -8($sp)
	sw $s1, -12($sp)
	jal IsInBounds
	move $t7, $s0
	addi $t7, $t7, 2
	sw $t7, -8($sp)
	sw $s1, -12($sp)
	jal XYToIndex
	lb   $s7, SPACE
	lw $t0, -4($sp)
	beq $t0, $s7, Visit
	jal XYToIndex
	move $s0, $t7
	sw $s0, -8($sp)
	sw $s1, -12($sp)
	jal IsInBounds
	lw $t0, -4($sp)
	add $t0, $s4, $t0
	sb $s3, 0($t0)
	li $a0, 1
	li $v0, 1
	syscall
	jal PrintGrid

#This is my south method, it essentailly stores the x and y values
#then checks to see if they are in bounds of the grid.
#next it will move the "drill" for tunneling south (-2)
#then it will remove the #'s nessacary and re-print the grid.

south:
	addi $s1, $s1, 1
	sw $s0, -4($sp)
	sw $s1, -8($sp)
	sw $s0, -8($sp)
	sw $s1, -12($sp)
	jal IsInBounds
	move $t7, $s1
	addi $t7, $t7, 2
	sw $s0, -8($sp)
	sw $t7, -12($sp)
	jal XYToIndex
	lb   $s7, SPACE
	lw $t0, -4($sp)
	beq $t0, $s7, Visit
	jal XYToIndex
	move $s1, $t7
	sw $s0, -8($sp)
	sw $s1, -12($sp)
	jal IsInBounds
	lw $t0, -4($sp)
	add $t0, $s4, $t0
	sb $s3, 0($t0)
	li $a0, 2
	li $v0, 1
	syscall
	jal PrintGrid

#This is my west method, it essentailly stores the x and y values
#then checks to see if they are in bounds of the grid.
#next it will move the "drill" for tunneling west (-2)
#then it will remove the #'s nessacary and re-print the grid.

west:
	addi $s0, $s0, -1
	sw $s0, -4($sp)
	sw $s1, -8($sp)
	sw $s0, -8($sp)
	sw $s1, -12($sp)
	jal IsInBounds
	move $t7, $s0
	addi $t7, $t7, -2
	sw $t7, -8($sp)
	sw $s1, -12($sp)
	jal XYToIndex
	lb   $s7, SPACE
	lw $t0, -4($sp)
	beq $t0, $s7, Visit
	jal XYToIndex
	move $s0, $t7
	sw $s0, -8($sp)
	sw $s1, -12($sp)
	jal IsInBounds
	lw $t0, -4($sp)
	add $t0, $s4, $t0
	sb $s3, 0($t0)
	li $a0, 3
	li $v0, 1
	syscall
	jal PrintGrid

PrintGrid:
	sw	$v0, -16($sp)						# service code
	sw	$a0, -20($sp)						# grid string
	# new line
	la  $a0, newLine
	li  $v0, 4
	syscall

	la  $a0, grid								# load grid
	li  $v0, 4									# to print
	syscall											# execute
	# new line
	la  $a0, newLine
	syscall

endPrint:
	# restore the registers
	lw	$v0, -16($sp)
	lw	$a0, -20($sp)
	lw  $ra, -24($sp)
	addi $t8, $t8, -1
	beqz $t8, exit
	lw $s0, -4($sp)
	lw $s1, -8($sp)
	j   Visit										# jump to exit

exit:
	li $v0, 10
	syscall
