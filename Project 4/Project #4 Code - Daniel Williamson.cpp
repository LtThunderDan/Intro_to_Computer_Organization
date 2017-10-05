/* 
Daniel Williamson
CS 200
3/10/16

This program takes in a floating point number from the user and displays a bit-level analysis of said floating point number.
*/

#include "stdafx.h"
#include <iostream>
#include <string>
using namespace std;
void errorMessage(char);
string usersInput;

//an error message for when there is an error. 
void errorMessage(char sign) 
{
	cout << "\nFloat Analysis\n";
	cout << "    Bit Pattern:    " << to_string(sign) << " 00000000 00000000000000000000000\n";
	cout << "                    S Exponent Significand\n";
	cout << " Your number can't be represented as a floating point number in binary!\n";
}

int main(int argc, const char * argv[])
{
	unsigned int intPart, decimalPosition;
	unsigned char charExponent, sign;
	unsigned i;
	float decimalFloat;
	string intPartString, decimalPartString, exponent, significand;


	//Users Input
	cout << "Please enter a floating point number: ";
	cin >> usersInput;

	//Finding a decimal, if there is one.
	(usersInput.find('.') != 4294967295) ? decimalPosition = usersInput.find('.') : decimalPosition = -1;

	//Figuring out if the float is positive or negative, if neither assume positive
	if (usersInput.find('-') == 0) 
	{
		sign = 1;
		intPart = (unsigned int)stoi(usersInput.substr(1, decimalPosition));
	}
	else if (usersInput.find('+') == 0) 
	{
		sign = 0;
		intPart = (unsigned int)stoi(usersInput.substr(1, decimalPosition));
	}
	else 
	{
		sign = 0;
		if (decimalPosition != -1 && decimalPosition != 0)
			intPart = (unsigned int)stoi(usersInput.substr(0, decimalPosition));
		else
			intPart = 0;
	}

	decimalFloat = (decimalPosition != -1) ? stof(usersInput.substr(decimalPosition, usersInput.length())) : 0;

	//Checks for +/- zero
	if (intPart + decimalFloat == 0.0) 
	{
		errorMessage(sign);
		return 0;
	}

	//converting intPart into binary
	for (i = 1 << (sizeof(intPart) * CHAR_BIT - 1); i > 0; i = i / 2)
		(intPart & i) ? intPartString += "1" : intPartString += "0";
	
	intPartString = intPartString.substr(
		(intPartString.find_first_of('1') != 4294967295) ? intPartString.find_first_of('1') + 1 :
		intPartString.length(), intPartString.length());
	charExponent = (intPartString != "") ? intPartString.length() : 0;

	//making of the significand
	for (int j = 1; j < 23 - intPartString.length() + 1; j++) 
	{
		float exponent = pow(2, -j);
		if (decimalFloat >= exponent) 
		{
			decimalFloat -= exponent;
			decimalPartString += "1";
		}
		else
			decimalPartString += "0";
	}

	//checks if dcimalFloat is not 0.0
	if (decimalFloat != 0 && decimalPartString.find('1') == 4294967295) 
	{
		errorMessage(sign);
		return 0;
	}
	else if ((intPartString == "" || intPart == 0) && decimalPartString.find('1') != 4294967295) 
	{
		charExponent = 0 - (decimalPartString.find('1') + 1);
	}

	//making everything into strings.
	//for the exponent
	charExponent += 127;
	for (i = 1 << (sizeof(charExponent) * CHAR_BIT - 1); i > 0; i = i / 2)
		(charExponent & i) ? exponent += "1" : exponent += "0";

	//for the significand
	significand = intPartString + decimalPartString;

	//for negative exponent, look for the first "1" and do some padding
	if (charExponent - 127 < 0) 
	{ 
		significand = significand.substr(abs(charExponent - 127), significand.length());
		significand += (string("0", abs(charExponent - 127)));
	}

	//printing all the info
	cout << "Float Analysis\n";
	cout << "    Bit Pattern:    " << to_string(sign) << " " << exponent << " " << significand << "\n";
	cout << "                    S Exponent Significand\n";
	cout << "    Sign:           " << to_string(sign); (to_string(sign) == "0") ? cout << " (positive)\n" : cout << " (negative)\n";
	cout << "    Exponent:       " << exponent << " = " << to_string(charExponent) << "; w/bias 127 -> (" << to_string(charExponent) << "-127) = " << to_string(charExponent - 127) << "\n";
	cout << "    Significand:    " << significand << "\n";
	cout << "      w/implied 1:  1." << significand << "\n";

	return 0;
}

