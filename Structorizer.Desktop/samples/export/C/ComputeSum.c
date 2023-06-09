// program ComputeSum 
// Generated by Structorizer 3.32-01 

// Copyright (C) 2020-03-21 Kay Gürtzig 
// License: GPLv3-link 
// GNU General Public License (V 3) 
// https://www.gnu.org/licenses/gpl.html 
// http://www.gnu.de/documents/gpl.de.html 

#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdbool.h>

// function readNumbers(fileName: string; numbers: array of integer; maxNumbers: integer): integer 

// Tries to read as many integer values as possible upto maxNumbers 
// from file fileName into the given array numbers. 
// Returns the number of the actually read numbers. May cause an exception. 
// TODO: Revise the return type and declare the parameters. 
int readNumbers(char* fileName, int numbers[50], int maxNumbers)
{
	// TODO: Check and accomplish variable declarations: 
	int number;
	int nNumbers;
	int fileNo;

	nNumbers = 0;
	fileNo = fileOpen(fileName);
	if (fileNo <= 0) {
		// FIXME: Structorizer detected this illegal jump attempt: 
		// throw "File could not be opened!" 
		goto __ERROR__;
	}
	// TODO: Find an equivalent for this non-supported try / catch block! 
// 	try { 
		while (! fileEOF(fileNo) && nNumbers < maxNumbers) {
			number = fileReadInt(fileNo);
			numbers[nNumbers] = number;
			nNumbers = nNumbers + 1;
		}
// 	} 
// 	catch(char error[]) { 
		// FIXME: jump/exit instruction of unrecognised kind! 
		// throw 
// 	} 
// 	finally { 
		fileClose(fileNo);
// 	} 
	return nNumbers;
}


// Computes the sum and average of the numbers read from a user-specified 
// text file (which might have been created via generateRandomNumberFile(4)). 
//  
// This program is part of an arrangement used to test group code export (issue 
// #828) with FileAPI dependency. 
// The input check loop has been disabled (replaced by a simple unchecked input 
// instruction) in order to test the effect of indirect FileAPI dependency (only the 
// called subroutine directly requires FileAPI now). 
int main(void)
{
	// TODO: Check and accomplish variable declarations: 
	??? values[50];
	double sum;
	int nValues;
	int k;
	??? file_name;
	int fileNo;

	// TODO: 
	// For any input using the 'scanf' function you need to fill the first argument. 
	// http://en.wikipedia.org/wiki/Scanf#Format_string_specifications 

	// TODO: 
	// For any output using the 'printf' function you need to fill the first argument: 
	// http://en.wikipedia.org/wiki/Printf#printf_format_placeholders 

	fileNo = 1000;
	// TODO: check format specifiers, replace all '?'! 
	// Disable this if you enable the loop below! 
	printf("Name/path of the number file"); scanf("%?", &file_name);
	// If you enable this loop, then the preceding input instruction is to be disabled 
	// and the fileClose instruction in the alternative below is to be enabled. 
// 	do { 
		// TODO: check format specifiers, replace all '?'! 
// 		printf("Name/path of the number file"); scanf("%?", &file_name); 
// 		fileNo = fileOpen(file_name); 
// 	} while (! (fileNo > 0 || file_name == "")); 
	if (fileNo > 0) {
		// This should be enabled if the input check loop above gets enabled. 
// 		fileClose(fileNo); 
		values[0] =;
		nValues = 0;
		// TODO: Find an equivalent for this non-supported try / catch block! 
// 		try { 
			nValues = readNumbers(file_name, values, 1000);
// 		} 
// 		catch(char failure[]) { 
			// TODO: check format specifiers, replace all '?'! 
// 			printf("%?\n", failure); 
// 			exit(-7); 
// 		} 
		sum = 0.0;
		for (k = 0; k <= nValues-1; k += (1)) {
			sum = sum + values[k];
		}
		// TODO: check format specifiers, replace all '?'! 
		printf("%s%g\n", "sum = ", sum);
		// TODO: check format specifiers, replace all '?'! 
		printf("%s%?\n", "average = ", sum / nValues);
	}

	return 0;
}
