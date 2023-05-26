/*
    Structorizer
    A little tool which you can use to create Nassi-Schneiderman Diagrams (NSD)

    Copyright (C) 2009  Bob Fisch

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or any
    later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package lu.fisch.structorizer.io;

/******************************************************************************************************
 *
 *      Author:         Kay Gürtzig
 *
 *      Description:    Abstract extended FileFilter class with file extension support
 *
 ******************************************************************************************************
 *
 *      Revision List
 *
 *      Author          Date            Description
 *      ------          ----            -----------
 *      Kay Gürtzig     2018-06-08      First Issue
 *      Kay Gürtzig     2020-12-13      Javadoc comments for getExtension methods
 *
 ******************************************************************************************************
 *
 *      Comment:
 *      getExtension() ensures a non-null return value (in case of a missing extension,
 *      an empty string will be returned)
 *
 ******************************************************************************************************///

import java.io.File;

import javax.swing.filechooser.FileFilter;
/**
 * This is an extended abstract subclass of {@link javax.swing.filechooser.FileFilter}
 * providing two basic static methods for file name extension extraction 
 * @author Kay Gürtzig
 */
public abstract class ExtFileFilter extends FileFilter {
	
	/**
	 * Extracts the file name extension of the given file path {@code s}
	 * @param s - a file path as string
	 * @return the extension as string or {@code ""} if there isn't any.
	 * @see #getExtension(File)
	 */
	public static String getExtension(String s) 
	{
		// START KGU#521 2018-06-08: Bugfix #536 We shouldn't return null in any case
		//String ext = null;
		String ext = "";
		// END KGU#521 2018-06-08
		// START KGU 2018-08-09: We must face cases where entire paths might be passed in
		s = (new File(s)).getName();
		// END KGU 2018-08-09
		int i = s.lastIndexOf('.');
		
		if (i > 0) 
		{
			ext = s.substring(i+1).toLowerCase();
		}
		return ext;
	}
	
	/**
	 * Extracts the file name extension of the given file {@code f}
	 * @param f - a {@link File} object
	 * @return the extension as string or {@code ""} if there isn't any.
	 * @see #getExtension(String)
	 */
	public static String getExtension(File f) 
	{
		return getExtension(f.getName());
	}

}
