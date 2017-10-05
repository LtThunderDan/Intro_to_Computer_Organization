// rle.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include<iostream>
#include<fstream>
#include<string>

using namespace std;

int main()
{
	cout << "Project 6: RLE Compression\n";
	//takes in a file and creates a string from it.
	ifstream inputFile("test.txt");
	string content((istreambuf_iterator<char>(inputFile)),
		(istreambuf_iterator<char>()));
	
	cout << "Info from File: "<< content << "\n";

	//Compresses the string into RLE and places it into an output.txt file and prints it out. 
	ofstream outPut("output.txt");
	cout << "Encoded value: ";
	int letter = 0;
	int number = content.length();
	while (letter < number) {
		int count = 1;
		while (letter < number && content[letter] == content[letter + 1]) {
			count++;
			letter++;
		}
		cout << content[letter] << count;
		outPut << content[letter] << count;
		letter++;
	}
	outPut.close();
	cout << "\n";

	//converts the outPut file into a string.
	ifstream outPutFile("output.txt");
	string outPutString(istreambuf_iterator<char>(outPutFile),
		(istreambuf_iterator<char>()));

	//Decodes the string from RLE by iterating through every other value starting at 0 and mutiplying it by every other value starting at 1. 
	cout << "Decoded value: ";
	for (unsigned int i = 0, j = 1; i < outPutString.length(), j < outPutString.length(); i = i + 2, j = j + 2) {
		//Subtract 48 from j, because c++ converts numbers into ASCII and 0 in ASCII is 48.
		int a = outPutString[j] - 48;
		string stuff(a, outPutString[i]);
		cout << stuff;
	}
	cout << "\n";
	return 0;
}