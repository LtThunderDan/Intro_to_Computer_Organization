
.data

GRID_WIDTH:			.word	80		# need to add 1 to print as string
GRID_HEIGHT:		.word	23
GRID_SIZE:			.word	1840		# because I can't precalculate it in
															# MIPS like I could in MASM
NORTH:					.word	0
EAST:						.word 1
SOUTH:					.word	2
WEST:						.word	3
RGEN:						.word	1073807359	# a sufficiently large prime for rand

POUND:					.byte	35		# the '#' character
SPACE:					.byte	32		# the ' ' character
NEWLINE:				.byte	10		# the newline character


rsdPrompt:			.asciiz "Enter a seed number (1073741824 - 2147483646): "
smErr1:					.asciiz "That number is too small, try again: "
bgErr:					.asciiz "That number is too large, try again: "
XY: 						.asciiz "XYToIndex: "
test1:					.asciiz "IsInBounds test #1: "
test2:					.asciiz "IsInBounds test #2: "
test3:					.asciiz "IsInBounds test #3: "
test4:					.asciiz "IsInBounds test #4: "
randomNumber:		.asciiz "Random Number: "
newLine:				.asciiz "\n"

grid:						.space	1841		# ((79 + 1) * 23) + 1 bytes reserved for grid
rSeed:					.word	0		# a seed for generating a random number

.text
.globl main

main:
	sw	$ra, 0($sp)	# save the return address
	jal	srand		# get a random seed
	jal	ResetGrid	# reset the grid to '#'s
	li	$t0, 1		# set up for start of generation at (1,1)
	sw	$t0, -4($sp)	# push first param
	sw	$t0, -8($sp) 	# push second param
	jal	Visit		# start the recursive generation
	jal Test
	jal	PrintGrid	# display the grid
	lw	$ra, 0($sp)	# restore the return address
	jr	$ra		# exit the program

ResetGrid:
	# It's a waste do do a stack frame when there are no parameters or
	# return values, so I'll optimize and simply push any register I use
	# onto the stack.  I need 7, a loop counter, a place to store the
	# loop bound for comparison, the base address of the grid, a register
	# to store the character value I will write, a register to store the
	# width of the grid, a register to store the newline character, and
	# finally, a register to hold calculation results.

	# save the registers
	sw	$s0, -4($sp)	# $s0 will be the loop counter
	sw	$s1, -8($sp)	# $s1 will hold the array bound
	sw	$s2, -12($sp)	# $s2 will be the grid base address
	sw	$s3, -16($sp)	# $s3 will hold the character
	sw	$s4, -20($sp)	# $s4 will hold the grid width
	sw  $s5, -24($sp) # $s5 will hold the newline character
	sw	$s6, -28($sp)	# $s6 used for calculations
	# NOTICE THAT I DON'T BOTHER MOVING THE STACK POINTER

	# load the working values
	li	$s0, 1		# initialize the counter
	lw	$s1, GRID_SIZE	# initialize the array bound
	la	$s2, grid	# get the base address
	lb	$s3, POUND	# store the '#' ASCII code
	lw	$s4, GRID_WIDTH # store the grid width
	lb	$s5, NEWLINE	# store the newline ASCII code

ResetLoop:
	sb	$s3, 0($s2)	# put a '#' in the grid
	addi	$s0, $s0, 1	# increment the loop counter
	addi	$s2, $s2, 1	# point at next char position
	div	$s0, $s4	# divide the counter by grid width
	mfhi	$s6		# get remainder in calculation register
	bnez	$s6, NoNewLine	# keep going

	sb	$s5, 0($s2)     # put a newline in the grid
	addi	$s0, $s0, 1	# increment the loop counter
	addi	$s2, $s2, 1	# point at next char position

NoNewLine:
	blt	$s0, $s1, ResetLoop	# if less than end, loop again

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
	sw	$v0, -4($sp)	# $v0 will be the service code
	sw	$a0, -8($sp)	# $a0 will point to the grid string
	sw	$s0, -12($sp)	# $s0 will hold the input for testing

	# prompt for a random seed and get the value
	la	$a0, rsdPrompt
	li	$v0, 4		# print_string
	syscall

input10:
	li	$v0, 5		# read_int
	syscall
	li	$s0, 1073741823		# put 2147483646 in t0 for comparison
	bgtu	$v0, $s0, input11	# input bigger than 1073741823?
	la	$a0, smErr1	# no, point to error and
	li	$v0, 4		# print_string
	syscall
	j	input10		# try again

input11:
	li	$s0, 2147483646	# upper bound in register t0 for comparison
	bleu	$v0, $s0, input12	# less than or equal 2147483646?
	la	$a0, bgErr	# no, point to error and
	li	$v0, 4		# print_string
	syscall
	j	input10		# try again

input12:
	# number is good, save and move on
	sw	$v0, rSeed

	# restore the registers
	lw	$v0, -4($sp)
	lw	$a0, -8($sp)
	lw	$s0, -12($sp)

	jr	$ra		# return

#==============================================================================
# rand(int min, int max)
#
# It uses the rSeed and RGEN values to create a new psuedo-random and a new
# seed for the next time this routine is called.  It range-fits the psuedo-
# random to the range min-max and returns it.  It does not need to formalize a
# stack frame since it doesn't call any other routines, so we simply set the
# two params and the return into the stack before calling and it begins pushing
# registers onto the stack above -12($sp).  Min is expected to be at -8($sp)
# and max is expected at -12($sp) while the return is at -4($sp).
#==============================================================================
rand:
	lw  $t0,  -8($sp)
	lw  $t1, -12($sp)

	lw $t2, RGEN
	lw $t3, rSeed

  multu $t2, $t3
  mflo $t5

  addu $t5, $t5, $t0
  div  $t5, $t1
	mfhi $t0

	sw  $t0,  -4($sp)
	jr	$ra

#==============================================================================
# int XYToIndex( int x, int y )
# Like rand, this uses the stack only for getting and returning values.
# -4($sp) is the return, -8($sp) is x, and -12($sp) is y.
#==============================================================================

XYToIndex:
	lw  $t0, GRID_WIDTH
	lw  $t1,  -8($sp)
	lw  $t2, -12($sp)

	mul $t2, $t2, $t0
	add $t2, $t2, $t1

	sw  $t2,  -4($sp)
	jr	$ra

#===============================================================================
# int IsInBounds( int x, int y )
# Like rand, this uses the stack only for getting and returning values.  -4($sp)
# is the return, -8($sp) is x, and -12($sp) is y.  Note that because we use a
# width that has an extra character, our first test is actually:
# 	if (x < 0 || x > GRID_WIDTH) return false;
#===============================================================================

IsInBounds:
	lw  $t0,  -8($sp)
	lw  $t1, -12($sp)
	lw  $t2, GRID_WIDTH
	lw  $t3, GRID_HEIGHT

	blt $t0, 0, retFalse
	bge $t0, $t2, retFalse
	blt $t1, 0, retFalse
	bge $t1, $t3, retFalse
	li $t4, 1
	j end

retFalse:
	li $t4, 0

end:
	sw $t4, -4($sp)
	jr	$ra

#===============================================================================
Visit:

	# TO DO:  You won't need this for project 9; it is just a placeholder
	#         for project 10.

	jr 	$ra
#===============================================================================

PrintGrid:
	# This is even easier than the C++ code because I've set the grid up as
	# one long string so you can simply use a system service to print it to
	# the console. Doing character by character printing in MASM was more
	# complicated. We need to preserve 2 registers, $v0 and $a0 used for
	# this system service.

	sw	$v0, -16($sp)
	sw	$a0, -20($sp)

	la  $a0, newLine
	li  $v0, 4
	syscall

	la  $a0, grid
	li  $v0, 4
	syscall

	la  $a0, newLine
	syscall
	syscall

	lw	$v0, -16($sp)
	lw	$a0, -20($sp)
	jr	$ra

#This method does some testing to make sure everything is working properly
#First we check the XYToIndex method.
#Second we test weather the inputs are IsInBounds.
#There are four tests, one at (0,0) which should be true and return a 1.
#one at (-15,0) which should be false and return a 0.
#one at (0,30) which should be false and return a 0.
#one at (10, 10) which should be true and return a 1.
#and then a rand test, to generate a random number.
#we have a min at 5, max at 10.

Test:
	sw   $ra, -16($sp)
	jal newLinePlease

	li   $t1, 9
	li   $t2, 5
	sw   $t1,  -8($sp)
	sw   $t2, -12($sp)
	jal  XYToIndex

	jal newLinePlease

	lw   $a0,  -4($sp)
	li   $v0, 1
	syscall

	jal newLinePlease

#test1
	li  $t1, 0
	li  $t2, 0
	sw  $t1,  -8($sp)
	sw  $t2, -12($sp)
	jal IsInBounds

	la 	 $a0, test1
	li 	 $v0, 4
	syscall

	lw  $a0,  -4($sp)
	li  $v0, 1
	syscall

	jal newLinePlease
#test2
	li  $t1, -15
	li  $t2, 0
	sw  $t1,  -8($sp)
	sw  $t2, -12($sp)
	jal IsInBounds

	la 	 $a0, test2
	li 	 $v0, 4
	syscall

	lw  $a0,  -4($sp)
	li  $v0, 1
	syscall

	jal newLinePlease
#test3
	li  $t1, 0
	li  $t2, 30
	sw  $t1,  -8($sp)
	sw  $t2, -12($sp)
	jal IsInBounds

	la 	 $a0, test3
	li 	 $v0, 4
	syscall

	lw  $a0,  -4($sp)
	li  $v0, 1
	syscall

	jal newLinePlease
#test4
	li  $t1, 10
	li  $t2, 10
	sw  $t1,  -8($sp)
	sw  $t2, -12($sp)
	jal IsInBounds

	la 	 $a0, test4
	li 	 $v0, 4
	syscall

	lw  $a0,  -4($sp)
	li  $v0, 1
	syscall

	jal newLinePlease
#test rand
	li $t1, 5
	li $t2, 10
	sw  $t1,  -8($sp)
	sw  $t2, -12($sp)
	jal rand

	la 	 $a0, randomNumber
	li 	 $v0, 4
	syscall

	lw  $a0,  -4($sp)
	li  $v0, 1
	syscall

	lw  $ra, -16($sp)
	jr	$ra

newLinePlease:
	la  $a0, newLine
	li  $v0, 4
	syscall
	jr 	$ra
