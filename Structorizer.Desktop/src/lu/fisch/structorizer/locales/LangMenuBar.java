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
package lu.fisch.structorizer.locales;

/*
 ******************************************************************************************************
 *
 *     Author: Bob Fisch
 *
 *     Description: This class extends a "JDialog" to support language settings
 *
 ******************************************************************************************************
 *
 *     Revision List
 *
 *     Author       Date        Description
 *     ------       ----        -----------
 *     Bob Fisch    2008.01.14  First Issue
 *     Bob Fisch    2016.08.02  Fundamentally redesigned
 *
 ******************************************************************************************************
 *
 * Comment:	/
 *
 *****************************************************************************************************
 */

import javax.swing.JMenuBar;

/**
 *
 * @author robertfisch
 */
@SuppressWarnings("serial")
public class LangMenuBar extends JMenuBar {

    public LangMenuBar() {
        super();
        Locales.getInstance().register(this);
    }
    
}
