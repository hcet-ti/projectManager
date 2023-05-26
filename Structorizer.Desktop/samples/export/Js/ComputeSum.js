<script>
// program ComputeSum 
// Generated by Structorizer 3.32-01 

// Copyright (C) 2020-03-21 Kay Gürtzig 
// License: GPLv3-link 
// GNU General Public License (V 3) 
// https://www.gnu.org/licenses/gpl.html 
// http://www.gnu.de/documents/gpl.de.html 

// function readNumbers(fileName: string; numbers: array of integer; maxNumbers: integer): integer 
// Tries to read as many integer values as possible upto maxNumbers 
// from file fileName into the given array numbers. 
// Returns the number of the actually read numbers. May cause an exception. 
function readNumbers(fileName, numbers, maxNumbers) {
	var number;
	var nNumbers;
	var fileNo;

	nNumbers = 0;
	fileNo = fileOpen(fileName);
	if (fileNo <= 0) {
		throw "File could not be opened!";
	}
	try {
		while (! fileEOF(fileNo) && nNumbers < maxNumbers) {
			number = fileReadInt(fileNo);
			numbers[nNumbers] = number;
			nNumbers = nNumbers + 1;
		}
	}
	catch (ex75fbd788) {
		error = ex75fbd788.message
		throw ex75fbd788;
	}
	finally {
		fileClose(fileNo);
	}
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

var values;
var sum;
var nValues;
var k;
// Disable this if you enable the loop below! 
var file_name;
var fileNo;

fileNo = 1000;
// Disable this if you enable the loop below! 
file_name = prompt("Name/path of the number file");
// If you enable this loop, then the preceding input instruction is to be disabled 
// and the fileClose instruction in the alternative below is to be enabled. 
// do { 
// 	file_name = prompt("Name/path of the number file"); 
// 	fileNo = fileOpen(file_name); 
// } while (! (fileNo > 0 || file_name == "")); 
if (fileNo > 0) {
	// This should be enabled if the input check loop above gets enabled. 
// 	fileClose(fileNo); 
	values = [];
	nValues = 0;
	try {
		nValues = readNumbers(file_name, values, 1000);
	}
	catch (ex416be80b) {
		failure = ex416be80b.message
		document.write((failure) + "<br/>");
		exit(-7);
	}
	sum = 0.0;
	for (k = 0; k <= nValues-1; k += (1)) {
		sum = sum + values[k];
	}
	document.write(("sum = ", sum) + "<br/>");
	document.write(("average = ", sum / nValues) + "<br/>");
}
</script>
