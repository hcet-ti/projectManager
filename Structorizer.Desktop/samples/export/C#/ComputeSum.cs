// Generated by Structorizer 3.32-01 

// Copyright (C) 2020-03-21 Kay Gürtzig 
// License: GPLv3-link 
// GNU General Public License (V 3) 
// https://www.gnu.org/licenses/gpl.html 
// http://www.gnu.de/documents/gpl.de.html 

using System;

/// <summary>
/// Computes the sum and average of the numbers read from a user-specified
/// text file (which might have been created via generateRandomNumberFile(4)).
/// 
/// This program is part of an arrangement used to test group code export (issue
/// #828) with FileAPI dependency.
/// The input check loop has been disabled (replaced by a simple unchecked input
/// instruction) in order to test the effect of indirect FileAPI dependency (only the
/// called subroutine directly requires FileAPI now).
/// </summary>
public class ComputeSum {

	/// <param name="args"> array of command line arguments </param>
	public static void Main(string[] args) {

		// TODO: Check and accomplish variable declarations: 
		???[] values;
		double sum;
		int nValues;
		??? file_name;
		int fileNo;

		// TODO: You may have to modify input instructions, 
		//       possibly by enclosing Console.ReadLine() calls with 
		//       Parse methods according to the variable type, e.g.: 
		//          i = int.Parse(Console.ReadLine()); 

		fileNo = 1000;
		// Disable this if you enable the loop below! 
		Console.Write("Name/path of the number file"); file_name = Console.ReadLine();
		// If you enable this loop, then the preceding input instruction is to be disabled 
		// and the fileClose instruction in the alternative below is to be enabled. 
// 		do { 
// 			Console.Write("Name/path of the number file"); file_name = Console.ReadLine(); 
// 			fileNo = StructorizerFileAPI.fileOpen(file_name); 
// 		} while (! (fileNo > 0 || file_name == "")); 
		if (fileNo > 0) {
			// This should be enabled if the input check loop above gets enabled. 
// 			StructorizerFileAPI.fileClose(fileNo); 
			values = new ???[]{};
			nValues = 0;
			try {
				nValues = readNumbers(file_name, values, 1000);
			}
			catch(Exception ex416be80b) {
				string failure = ex416be80b.ToString()
				Console.WriteLine(failure);
				if (System.Windows.Forms.Application.MessageLoop) {
					// WinForms app 
					System.Windows.Forms.Application.Exit();
				}
				else {
					// Console app 
					System.Environment.Exit(-7);
				}
			}
			sum = 0.0;
			for (int k = 0; k <= nValues-1; k += (1)) {
				sum = sum + values[k];
			}
			Console.Write("sum = "); Console.WriteLine(sum);
			Console.Write("average = "); Console.WriteLine(sum / nValues);
		}
	}

	/// <summary>
	/// Tries to read as many integer values as possible upto maxNumbers
	/// from file fileName into the given array numbers.
	/// Returns the number of the actually read numbers. May cause an exception.
	/// </summary>
	/// <param name="fileName"> TODO </param>
	/// <param name="numbers"> TODO </param>
	/// <param name="maxNumbers"> TODO </param>
	/// <return> TODO </return>
	private static int readNumbers(string fileName, int[] numbers, int maxNumbers) {
		// TODO: Check and accomplish variable declarations: 
		int number;
		int nNumbers;
		int fileNo;

		nNumbers = 0;
		fileNo = StructorizerFileAPI.fileOpen(fileName);
		if (fileNo <= 0) {
			// FIXME: You should replace System.Exception by an own subclass! 
			throw new System.Exception("File could not be opened!");
		}
		try {
			while (! StructorizerFileAPI.fileEOF(fileNo) && nNumbers < maxNumbers) {
				number = StructorizerFileAPI.fileReadInt(fileNo);
				numbers[nNumbers] = number;
				nNumbers = nNumbers + 1;
			}
		}
		catch(Exception ex75fbd788) {
			string error = ex75fbd788.ToString()
			throw;
		}
		finally {
			StructorizerFileAPI.fileClose(fileNo);
		}
		return nNumbers;
	}

}
