/*
Project3
By: Daniel Williamson
CS 200
2/26/16
*/
//Necessary for the standard library
#include <stdio.h>

//this method prints out the inputted integers into decimal form with padding of 0's
void Decimal(unsigned int number){
  printf("%03d" , number);
}

//this method prints out the inputted integers into hexadecimal
void Hex(unsigned int number){
  printf("%#08x", number);
}

//this method prints out the inputted integers into binary up to 8 bits long
void Binary(unsigned int number){
  unsigned int n;
  for (n = 1 << 7; n > 0; n = n / 2)
      (number & n)? printf("1"): printf("0");
}

//main method that takes in the input from the user and prints it out all nice.
int main(int argc, const char * argv[]) {

  unsigned int num1;
  unsigned int num2;

  //input from user comes from here
  printf("Your first number between 0 and 255: ");
  scanf("%d", &num1);
  printf("Your second number between 0 and 255: ");
  scanf("%d", &num2);

  //making of the output to look readable
  printf("          Decimal       Hexidecimal        Binary \n");
  printf("Num1 =        "),Decimal(num1);
  printf("          "),Hex(num1);
  printf("      "),Binary(num1);
  printf("\n");
  printf("Num2 =        "),Decimal(num2);
  printf("          "),Hex(num2);
  printf("      "),Binary(num2);
  printf("\n");
  printf("Num1 & Num2 = "),Decimal(num1&num2);
  printf("          "),Hex(num1&num2);
  printf("      "),Binary(num1&num2);
  printf("\n");
  printf("Num1 | Num2 = "),Decimal(num1|num2);
  printf("          "),Hex(num1|num2);
  printf("      "),Binary(num1|num2);
  printf("\n");
  printf("Num1 ^ Num2 = "),Decimal(num1^num2);
  printf("          "),Hex(num1^num2);
  printf("      "),Binary(num1^num2);
  printf("\n");
  printf("~Num1 =       "),Decimal(~num1);
  printf("          "),Hex(~num1);
  printf("      "),Binary(~num1);
  printf("\n");
  printf("Num1>>Num2 =  "),Decimal(num1>>num2);
  printf("          "),Hex(num1>>num2);
  printf("      "),Binary(num1>>num2);
  printf("\n");
  printf("Num1<<Num2 =  "),Decimal(num1<<num2);
  printf("          "),Hex(num1<<num2);
  printf("      "),Binary(num1<<num2);
  printf("\n");

  //this stops the .exe from closing the cmd after running
  getch();

  return 0;
}
