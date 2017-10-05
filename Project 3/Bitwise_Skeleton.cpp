// Bitwise.cpp : Patrick Kelley 2012
//
// Takes two integers between 0 and 255 and performs some standard bitwise
// operations on them, printing the results in binary, hex, and decimal.
// Includes my own functions to convert the results to base-formatted strings
// because why not?  Good practice for base conversions.
//

#include "stdafx.h"
#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "iostream"

using namespace std;

// Function declarations
void byteToDecimalStr(char, TCHAR*);
void byteToBinaryStr(char, TCHAR*);
void byteToHexStr(char, TCHAR*);

// This is the main routine that triggers everything else
int _tmain(int argc, TCHAR* argv[])
{

	// TO DO: All the code for input here

	// force inputs to 8 bits ('char' just happens to be 8 bits long)
	num1byte = (char)num1;
	num2byte = (char)num2;

	// print header
	cout << "         Decimal    Hexidecimal    Binary" << endl;

	// format input 1 and print  EXAMPLES OF HOW TO DO THE OUTPUT
	byteToDecimalStr(num1byte, (TCHAR*)&decimalOut);
	byteToHexStr(num1byte, (TCHAR*)&hexOut);
	byteToBinaryStr(num1byte, (TCHAR*)&binaryOut);
	wcout << "A =        " << (TCHAR[4])decimalOut << "          ";
	wcout << (TCHAR[3])hexOut << "h       " << (TCHAR[9])binaryOut << "b" << endl;

	// format input 2 and print
	byteToDecimalStr(num2byte, (TCHAR*)&decimalOut);
	byteToHexStr(num2byte, (TCHAR*)&hexOut);
	byteToBinaryStr(num2byte, (TCHAR*)&binaryOut);
	wcout << "B =        " << (TCHAR[4])decimalOut << "          ";
	wcout << (TCHAR[3])hexOut << "h       " << (TCHAR[9])binaryOut << "b" << endl;

	// TO DO:  Get the results from the various operations and output them
	// similarly to the above

	// all done, end the program
	return 0;
}

// void byteToDecimalStr( char, TCHAR*)
// This function takes an integer (forced to a byte length) and the address of a character
// string as its inputs.  It will convert the value of the integer to a decimal by dividing
// the number by the base 10 and adding extracted digits in the remainder to a string that is
// returned in the address passed in the inputs.  There is no error checking - any possible
// byte value is valid and it is up to the user to provide reasonable inputs.  The result
// string is padded with leading 0s up to a 3-digit field (255 is the max for one byte).
void byteToDecimalStr(char num, TCHAR* rstr){
	// Sorry, no code. This works like byteToBinaryStr() but with more cases in the
	// case statement (for all the digits 0-9).  If you are using C instead of C++,
	// you can use the built-in formatting in fprint and don't need this routine.

}

// void byteToBinaryStr( char, TCHAR*)
// This function takes an integer (forced to a byte length) and the address of a character
// string as its inputs.  It will convert the value of the integer to a binary by dividing
// the number by the base 2 and adding extracted digits in the remainder to a string that is
// returned in the address passed in the inputs.  There is no error checking - any possible
// byte value is valid and it is up to the user to provide reasonable inputs.  The result
// string is padded with leading 0s up to an 8-digit field (11111111 is the max for one byte).
void byteToBinaryStr(char num, TCHAR* rstr){
	// declare some temporary variables to work with
	TCHAR resultStr[9];
	TCHAR tempStr[9];
	unsigned char tnum = (unsigned char)num;
	unsigned char remainder;
	int cnt = 8;		// this is for padding leading 0s

	_tcscpy_s(resultStr, 9, _T(""));		// start with a blank string
	while (cnt != 0){				// loop until all digits are added
		remainder = tnum % 2;		// use modulo to get the digit
		tnum = tnum / 2;			// reduce the number for the next iteration
		switch (remainder){			// based on the digit, get a character
			case 0:
				_tcscpy_s(tempStr, 9, _T("0"));
				break;
			case 1:
				_tcscpy_s(tempStr, 9, _T("1"));
				break;
		}

		_tcscat_s(tempStr, 9, resultStr);  // add the digit to the front
		_tcscpy_s(resultStr, 9, tempStr);
		cnt--;
	}

	_tcscpy_s(rstr, 9, resultStr);
}

// void byteToHexStr( char, TCHAR*)
// This function takes an integer (forced to a byte length) and the address of a character
// string as its inputs.  It will convert the value of the integer to a hexadecimal by dividing
// the number by the base 16 and adding extracted digits in the remainder to a string that is
// returned in the address passed in the inputs.  There is no error checking - any possible
// byte value is valid and it is up to the user to provide reasonable inputs.  The result
// string is padded with leading 0s up to a 2-digit field (FF is the max for one byte).
void byteToHexStr(char num, TCHAR* rstr){
	// Sorry, no code. This works like byteToBinaryStr() but with more cases in the
	// case statement (for all the digits 0-9).  If you are using C instead of C++,
	// you can use the built-in formatting in fprint and don't need this routine.

}
