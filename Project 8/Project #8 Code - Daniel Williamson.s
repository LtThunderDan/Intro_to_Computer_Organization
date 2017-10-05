#Daniel Williamson 4/15/16
#Project 8 - Bubble sort

#This project asks for user input on, how many numbers to be bubble sorted and
#the numbers that are needed to be sorted. Then, using bubble sort, sorts the
#entered values from least to greatest with a comma delimiter.

#delcaring of variables for later use.
#dummy variables neeeded to just hold values tell they get changed.

.data
  dummyVar1:    .word         1
  dummyVar2:    .word         10
  counter:      .word         1

  userInput1:   .asciiz       "\nHow many numbers should we sort? Must be between 1 and 10: "
  userInput2:   .asciiz       "Please enter a number: "
  userError:    .asciiz       "That is not between 1 and 10, incorrect input, try again."
  sortedNumbers:.asciiz       "Your sorted numbers are:\n"
  delimiter:    .asciiz       ", "
.text

#main method takes user input and stores it.
#also does a lot of branching to other methods.

.globl main
main:
  lw $t0, dummyVar1
  lw $t1, dummyVar2
  jal ReadNums
  sw $s1, counter
  lw $s0, counter

  move $a0, $sp
  move $a2, $a0
  lw $a1, counter
  jal bSort

  lw $s0, counter
  jal PrintNums

#ReadNums, where we read numbers.
#takes in the numbers that were loaded into memory from main and reads them.
#makes sure the user did not incorrect enter an invalid number of numbers. i.e. 1-10
#if they did, print off an error message and restart.

ReadNums:
  la $a0, userInput1
  li $v0, 4
  syscall
  li $v0, 5
  syscall
  move $s0, $v0
  blt $s0, $t0, countErr
  bgt $s0, $t1, countErr
  move $s1, $s0
readNumsLoop:
  beq $s0, $zero, return
  sub $s0, $s0, $t0
  la $a0, userInput2
  li $v0, 4
  syscall
  li $v0, 5
  syscall
  addi $sp, $sp, -4
  sw $v0, 0($sp)
  j readNumsLoop
countErr:
  la $a0, userError
  li $v0, 4
  syscall
  j ReadNums

#bSort, where the magic happens.
#compares two numbers and loads the larger one into memory.
#keeps comparing tell it finds a larger one. if there is one.
#if not, dump it off at the end of the list and do it all over again.
#two loops needed to keep track of the sorting and the comparing of numbers.

bSort:
  move $t0, $zero
loopTwo:
  addi $t0, $t0, 1
  bgt $t0, $a1, return

  add $t1, $a1, $zero
loopOne:
  bge $t0, $t1, loopTwo
  addi $t1, $t1, -1

  mul $t4, $t1, 4
  addi $t3, $t4, -4

  add $t7, $t4, $a2
  add $t8, $t3, $a2

  lw $t5, 0($t7)
  lw $t6, 0($t8)

  bgt $t5, $t6, loopOne
  sw $t5, 0($t8)
  sw $t6, 0($t7)
  j loopOne

#PrintsNums, where we print off our sorted numbers.
#PrintNumsLoop needed to loop through array of sorted numbers
#and print them off one at a time. With a delimiter of ", "

PrintNums:
  move $fp, $sp
  la $a0, sortedNumbers
  li $v0, 4
  syscall

PrintNumsLoop:
  beq $s0, $zero, return
  addi $s0, $s0, -1
  lw $a0, 0($fp)
  li $v0, 1
  syscall
  la $a0, delimiter
  li $v0, 4
  syscall
  addi $fp, $fp, 4
  j PrintNumsLoop

return:
  jr $ra
