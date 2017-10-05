#Declaring of Variables.
.data
      # Strings for user input
      getSeed:      .asciiz "Enter a Seed(x): "
      getInc:       .asciiz "\nEnter number to increment seed by: "
      getMod:       .asciiz "\nEnter number to modulate seed by: "
      getLoops:     .asciiz "\nEnter how many numbers you would like: "
      finalResult:  .asciiz "\nYour random numbers are: \n"
      getSpace:     .asciiz "\n"

      #Dummy variables stores the user's input in memory.
      dummyLoops:   .word 1
      dummyMult:    .word 22695477 # Borland C/C++, found on wikipedia
      dummyX:       .word 1
      dummyInc:     .word 1
      dummyMod:     .word 1
.text
.globl main
# Places values from the registers into my variables
holdValues:
    sw $t0, dummyX
    sw $t1, dummyLoops
    sw $t2, dummyInc
    sw $t3, dummyMod
    jr $ra

# The program starts here
main:
# Gets users input and loads them into the appropriate registers
# which gets stored into memory then starts calculating
getUserInput:
    la $a0, getSeed
    li $v0, 4
    syscall
    li $v0, 5
    syscall

    move $t0, $v0

    la $a0, getLoops
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    move $t1, $v0

    la $a0, getInc
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    move $t2, $v0

    la $a0, getMod
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    move $t3, $v0

    jal holdValues

    la $a0, finalResult
    li $v0, 4
    syscall

    move $s3, $t1

# For Loop, keeps track of counter until it is less then 1.
# If it is greater than one, continue doing calculations.
# Then print out the generated random numbers.
# Else returns to the main method.
forLoop:
    blt $s3, 1, main
    sub $s3, $s3, 1
    jal modulusCalc

    move $a0, $v0
    li $v0, 1
    syscall

    la $a0, getSpace
    li $v0, 4
    syscall
    b forLoop

# Does computation of recurrence relation "(aX + C) mod m"
recurrenceCalc:
    lw $t0, dummyX
    lw $t2, dummyInc
    lw $t3, dummyMod
    lw $t4, dummyMult

    multu $t0, $t4
    mflo $v0
    addu $v0, $v0, $t2
    sw $v0, dummyX
    jr $ra

# Does modulus calculation of equation listed above.
modulusCalc:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    jal recurrenceCalc

    divu $v0, $t3
    mfhi $v0
    lw $ra, 0($sp)
    addi $sp, $sp, -8
    jr $ra
