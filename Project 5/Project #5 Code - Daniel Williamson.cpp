// Project_5_Code.cpp : Defines the entry point for the console application.
/*
Daniel Williamson
CS 200
3/11/16

This program takes in a users input and creates an encoded message, then decodes it all while using base64 encoding.
*/
#include "stdafx.h"
#include <iostream>
#include <string>

using namespace std;

string encode(char*, unsigned int);
string decode(string const&);
bool isValid(unsigned char);
string base64Symbols = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

//main method. takes in users input and prints out the encoded and decoded values.
int main() {
	char usersInput[80];

	cout << "Enter text: ";
	cin >> usersInput;

	int usersInputLength = strlen(usersInput);

	cout << "You typed in \"" << usersInput << "\" (" << usersInputLength << " chars)" << "\n";

	string encodedStr = encode(usersInput, usersInputLength);
	string decodedStr = decode(encodedStr);

	cout << "Encoded Value: " << encodedStr << "\nDecoded Value: " << decodedStr << "\n";

	return 0;
}

//decoder method, decodes our encoded values with shifting and masking.
string decode(string const& encodeStr) {
	size_t stringLength = encodeStr.size(), groupChars = 0, remainingChars = 0;
	int counter = 0;
	unsigned char charsEncode[4], charsDecode[3];
	string result;

	//while there are still values to decode.
	while (stringLength-- && (encodeStr[counter] != '=') && isValid(encodeStr[counter])) 
	{
		charsEncode[groupChars++] = encodeStr[counter];
		counter++;
		//if there are 4 chars do some shifting and masking to decode and place in the results.
		if (groupChars == 4) 
		{
			for (groupChars = 0; groupChars <4; groupChars++)
				charsEncode[groupChars] = base64Symbols.find(charsEncode[groupChars]);
			charsDecode[0] = (charsEncode[0] << 2) + ((charsEncode[1] & 0x30) >> 4);
			charsDecode[1] = ((charsEncode[1] & 0xF) << 4) + ((charsEncode[2] & 0x3C) >> 2);
			charsDecode[2] = ((charsEncode[2] & 0x3) << 6) + charsEncode[3];

			for (groupChars = 0; (groupChars < 3); groupChars++)
				result += charsDecode[groupChars];
			groupChars = 0;
		}
	}
	//if there are anymore do some shifting and masking to decode and put it in the results.
	if (groupChars) 
	{
		for (remainingChars = groupChars; remainingChars <4; remainingChars++)
			charsEncode[remainingChars] = 0;

		for (remainingChars = 0; remainingChars <4; remainingChars++)
			charsEncode[remainingChars] = base64Symbols.find(charsEncode[remainingChars]);

		charsDecode[0] = (charsEncode[0] << 2) + ((charsEncode[1] & 0x30) >> 4);
		charsDecode[1] = ((charsEncode[1] & 0xF) << 4) + ((charsEncode[2] & 0x3C) >> 2);
		charsDecode[2] = ((charsEncode[2] & 0x3) << 6) + charsEncode[3];

		for (remainingChars = 0; (remainingChars < groupChars - 1); remainingChars++) result += charsDecode[remainingChars];
	}

	return result;
}
//isValid method. Checks to see if encoded values are valid.
bool isValid(unsigned char character) {
	return (isalnum(character) || (character == '+') || (character == '/'));
}

//encode method. Encodes the usersInput with shifting and masking.
string encode(char* chars, unsigned int strLen) {
	string encodedValue;
	unsigned int charsToEncode = 0, remainingCharsToEncode = 0;
	unsigned char usersInputedChars[3], encodedChars[4];

	//While there are still values to encode.
	while (strLen--) 
	{ 
		usersInputedChars[charsToEncode++] = *(chars++);
		//if there is a group of 3 chars do some shifting and masking.
		if (charsToEncode == 3) 
		{
			encodedChars[0] = (usersInputedChars[0] & 0xFC) >> 2;
			encodedChars[1] = ((usersInputedChars[0] & 0x03) << 4) + ((usersInputedChars[1] & 0xF0) >> 4);
			encodedChars[2] = ((usersInputedChars[1] & 0xF) << 2) + ((usersInputedChars[2] & 0xC0) >> 6);
			encodedChars[3] = usersInputedChars[2] & 0x3F;

			//for all the encoded chars turn them into bse64Symbols and assign to results.
			for (charsToEncode = 0; (charsToEncode <4); charsToEncode++)
				encodedValue += base64Symbols[encodedChars[charsToEncode]];
			charsToEncode = 0;
		}
	}

	//if there are any remaining chars we do some shifting and masking and add them to results.
	//Also if there are any remaining unfilled chars we will pad with '='
	if (charsToEncode) 
	{
		for (remainingCharsToEncode = charsToEncode; remainingCharsToEncode < 3; remainingCharsToEncode++)
			usersInputedChars[remainingCharsToEncode] = '\0';

		encodedChars[0] = (usersInputedChars[0] & 0xFC) >> 2;
		encodedChars[1] = ((usersInputedChars[0] & 0x03) << 4) + ((usersInputedChars[1] & 0xF0) >> 4);
		encodedChars[2] = ((usersInputedChars[1] & 0xF) << 2) + ((usersInputedChars[2] & 0xC0) >> 6);
		encodedChars[3] = usersInputedChars[2] & 0x3F;

		for (remainingCharsToEncode = 0; (remainingCharsToEncode < charsToEncode + 1); remainingCharsToEncode++)
			encodedValue += base64Symbols[encodedChars[remainingCharsToEncode]];

		while ((charsToEncode++ < 3))
			encodedValue += '=';
	}
	return encodedValue;
}

