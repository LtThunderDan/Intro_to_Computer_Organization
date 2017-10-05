//
//  main.c
//  Project 3: Bitwise Ops
//
//  Created by Luis Arroyo on 2/22/16.
//  Copyright © 2016 Luis Arroyo. All rights reserved.
//  Program Language: C
//  Program: Xcode
//
//  Date: February 26, 2016
//  Class: CS 200-001
//  Professor: Patrick Kelley


/*
 The purpose this lab is to create a program that demonstrates various bitwise
 operations applied to two arbitrary integers.
 The result should be shown in decimal, hexadecimal, and binary.
*/


//What we will include:
//The standard library
#include <stdio.h>

//Defining the pre-declared functions:
void print_dec_hex_binary(unsigned int);

// Define the Global variables:
// It will take in 2 user inputs as unsigned integers
unsigned int a;
unsigned int b;

/*
 void print_dec_hex_binary(unsigned int);

 What this function does is take in an unsigned integer (number) as a parameter
 and it will convert it into a decimal hexadecimal, and a binary
*/
void print_dec_hex_binary(unsigned int number){
    //Prints the Decimal of the number
    printf("\nDecimal: %u\n", number);

    //Prints the hexadecimal conversion of the number
    //%#010x is a buillt-in that I got from
    //http:stackoverflow.com/questions/14733761/printf-formatting-for-hex
    //What it does is format it as hexadecimal.
    //if the integer entered is 9, it will convert it to 0x00000008
    printf("Hexadecimal: ");
    printf("%#010x\n", number);

    //Prints the binary conversion of the number
    //http://www.geeksforgeeks.org/binary-representation-of-a-given-number/
    unsigned n;
    printf("Binary: ");
    for (n = 1 << 15; n > 0; n = n / 2)
        (number & n)? printf("1"): printf("0");
    printf("\n\n\n");

}
int main(int argc, const char * argv[]) {

    //This will allow the user to enter a number in each statement as an input
    //Assuming that the user will not enter a letter or a number
    //between 0 and 65535
    printf("Hello user. Welcome to the Integer Converter.\n\n");
    printf("Please enter the first number between 0 and 65535: ");
    scanf("%u", &a);
    printf("Please enter the second number between 0 and 65535: ");
    scanf("%u", &b);

    //Prints the conversions for a
    printf("The values you entered are: \n\n");
    printf("a: %u", a);
    print_dec_hex_binary(a);

    //Prints the conversions for b
    printf("b: %u", b);
    print_dec_hex_binary(b);

    //Now we calculate each bitwise operation that was required
    printf("a & b= ");
    print_dec_hex_binary(a&b);

    printf("a | b= ");
    print_dec_hex_binary(a|b);

    printf("a ^ b= ");
    print_dec_hex_binary(a^b);

    printf("~a = ");
    print_dec_hex_binary(~a);

    printf("a >> b= ");
    print_dec_hex_binary(a>>b);

    printf("a << b= ");
    print_dec_hex_binary(a<<b);

    getch();

    return 0;
}
