10 REM Concept and lisp implementation published by Joseph Weizenbaum (MIT): 
20 REM "ELIZA - A Computer Program For the Study of Natural Language Communication Between Man and Machine" - In: 
30 REM Computational Linguistis 1(1966)9, pp. 36-45 
40 REM Revision history: 
50 REM 2016-10-06 Initial version 
60 REM 2017-03-29 Two diagrams updated (comments translated to English) 
70 REM 2017-03-29 More keywords and replies added 
80 REM 2019-03-14 Replies and mapping reorganised for easier maintenance 
90 REM 2019-03-15 key map joined from keyword array and index map 
100 REM 2019-03-28 Keyword "bot" inserted (same reply ring as "computer") 
110 REM 2019-11-28 New global type "History" (to ensure a homogenous array) 
120 REM Generated by Structorizer 3.32-01 
130 
140 REM Copyright (C) 2018-05-14 Kay Gürtzig 
150 REM License: GPLv3-link 
160 REM GNU General Public License (V 3) 
170 REM https://www.gnu.org/licenses/gpl.html 
180 REM http://www.gnu.de/documents/gpl.de.html 
190 
200 REM  
210 REM program ELIZA
220 REM TODO: add the respective type suffixes to your variable names if required 
230 REM Title information 
240 PRINT "************* ELIZA **************"
250 PRINT "* Original design by J. Weizenbaum"
260 PRINT "**********************************"
270 PRINT "* Adapted for Basic on IBM PC by"
280 PRINT "* - Patricia Danielson"
290 PRINT "* - Paul Hashfield"
300 PRINT "**********************************"
310 PRINT "* Adapted for Structorizer by"
320 PRINT "* - Kay Gürtzig / FH Erfurt 2016"
330 PRINT "* Version: 2.3 (2020-02-24)"
340 PRINT "* (Requires at least Structorizer 3.30-03 to run)"
350 PRINT "**********************************"
360 REM Stores the last five inputs of the user in a ring buffer, 
370 REM the second component is the rolling (over-)write index. 
380 DIM history AS History
390 LET history.histArray = {"", "", "", "", ""}
400 LET history.histIndex = 0
410 LET replies = setupReplies()
420 LET reflexions = setupReflexions()
430 LET byePhrases = setupGoodByePhrases()
440 LET keyMap = setupKeywords()
450 LET offsets(length(keyMap)-1) = 0
460 LET isGone = false
470 REM Starter 
480 PRINT "Hi! I\'m your new therapist. My name is Eliza. What\'s your problem?"
490 DO
500   INPUT userInput
510   REM Converts the input to lowercase, cuts out interpunctation 
520   REM and pads the string 
530   LET userInput = normalizeInput(userInput)
540   LET isGone = checkGoodBye(userInput, byePhrases)
550   IF NOT isGone THEN
560     LET reply = "Please don\'t repeat yourself!"
570     LET isRepeated = checkRepetition(history, userInput)
580     IF NOT isRepeated THEN
590       LET findInfo = findKeyword(keyMap, userInput)
600       LET keyIndex = findInfo(0)
610       IF keyIndex < 0 THEN
620         REM Should never happen... 
630         LET keyIndex = length(keyMap)-1
640       END IF
650       LET var entry: KeyMapEntry = keyMap(keyIndex)
660       REM Variable part of the reply 
670       LET varPart = ""
680       IF length(entry.keyword) > 0 THEN
690         LET varPart = conjugateStrings(userInput, entry.keyword, findInfo(1), reflexions)
700       END IF
710       LET replyRing = replies(entry.index)
720       LET reply = replyRing(offsets(keyIndex))
730       LET offsets(keyIndex) = (offsets(keyIndex) + 1) % length(replyRing)
740       LET posAster = pos("*", reply)
750       IF posAster > 0 THEN
760         IF varPart = " " THEN
770           LET reply = "You will have to elaborate more for me to help you."
780         ELSE
790           delete(reply, posAster, 1)
800           insert(varPart, reply, posAster)
810         END IF
820       END IF
830       LET reply = adjustSpelling(reply)
840     END IF
850     PRINT reply
860   END IF
870 LOOP UNTIL isGone
880 END
890 REM  
900 REM Cares for correct letter case among others 
910 REM TODO: Add type-specific suffixes where necessary! 
920 FUNCTION adjustSpelling(sentence AS String) AS String
930   REM TODO: add the respective type suffixes to your variable names if required 
940   LET result = sentence
950   LET position = 1
960   DO WHILE (position <= length(sentence)) AND (copy(sentence, position, 1) = " ")
970     LET position = position + 1
980   LOOP
990   IF position <= length(sentence) THEN
1000     LET start = copy(sentence, 1, position)
1010     delete(result, 1, position)
1020     insert(uppercase(start), result, 1)
1030   END IF
1040   DIM arraydbdbf287() AS String = {" i ", " i\'"}
1050   FOR EACH word IN arraydbdbf287
1060     LET position = pos(word, result)
1070     DO WHILE position > 0
1080       delete(result, position+1, 1)
1090       insert("I", result, position+1)
1100       LET position = pos(word, result)
1110     LOOP
1120   NEXT word
1130   RETURN result
1140 END FUNCTION
1150 REM  
1160 REM Checks whether the given text contains some kind of 
1170 REM good-bye phrase inducing the end of the conversation 
1180 REM and if so writes a correspding good-bye message and 
1190 REM returns true, otherwise false 
1200 REM TODO: Add type-specific suffixes where necessary! 
1210 FUNCTION checkGoodBye(text AS String, phrases AS String(50,0 TO 1)) AS boolean
1220   REM TODO: add the respective type suffixes to your variable names if required 
1230   FOR EACH pair IN phrases
1240     IF pos(pair(0), text) > 0 THEN
1250       PRINT pair(1)
1260       RETURN true
1270     END IF
1280   NEXT pair
1290   return false
1300 END FUNCTION
1310 REM  
1320 REM TODO: Add type-specific suffixes where necessary! 
1330 FUNCTION conjugateStrings(sentence AS String, key AS String, keyPos AS integer, flexions AS String(50,0 TO 1)) AS String
1340   REM TODO: add the respective type suffixes to your variable names if required 
1350   LET result = " " + copy(sentence, keyPos + length(key), length(sentence)) + " "
1360   FOR EACH pair IN flexions
1370     LET left = ""
1380     LET right = result
1390     LET position = pos(pair(0), right)
1400     DO WHILE position > 0
1410       LET left = left + copy(right, 1, position-1) + pair(1)
1420       LET right = copy(right, position + length(pair(0)), length(right))
1430       LET position = pos(pair(0), right)
1440     LOOP
1450     LET result = left + right
1460   NEXT pair
1470   REM Eliminate multiple spaces 
1480   LET position = pos("  ", result)
1490   DO WHILE position > 0
1500     LET result = copy(result, 1, position-1) + copy(result, position+1, length(result))
1510     LET position = pos("  ", result)
1520   LOOP
1530   RETURN result
1540 END FUNCTION
1550 REM  
1560 REM Converts the sentence to lowercase, eliminates all 
1570 REM interpunction (i.e. ',', '.', ';'), and pads the 
1580 REM sentence among blanks 
1590 REM TODO: Add type-specific suffixes where necessary! 
1600 FUNCTION normalizeInput(sentence AS String) AS String
1610   REM TODO: add the respective type suffixes to your variable names if required 
1620   LET sentence = lowercase(sentence)
1630   REM TODO: Specify an appropriate element type for the array! 
1640   DIM arraybd738552() AS FIXME_bd738552 = {'.', ',', ';', '!', '?'}
1650   FOR EACH symbol IN arraybd738552
1660     LET position = pos(symbol, sentence)
1670     DO WHILE position > 0
1680       LET sentence = copy(sentence, 1, position-1) + copy(sentence, position+1, length(sentence))
1690       LET position = pos(symbol, sentence)
1700     LOOP
1710   NEXT symbol
1720   LET result = " " + sentence + " "
1730   RETURN result
1740 END FUNCTION
1750 REM  
1760 REM TODO: Add type-specific suffixes where necessary! 
1770 FUNCTION setupGoodByePhrases() AS String(50,0 TO 1)
1780   REM TODO: add the respective type suffixes to your variable names if required 
1790   REM TODO: Check indexBase value (automatically generated) 
1800   LET indexBase = 0
1810   LET phrases(0)(indexBase + 0) = " shut"
1820   LET phrases(0)(indexBase + 1) = "Okay. If you feel that way I\'ll shut up. ... Your choice."
1830   REM TODO: Check indexBase value (automatically generated) 
1840   LET indexBase = 0
1850   LET phrases(1)(indexBase + 0) = "bye"
1860   LET phrases(1)(indexBase + 1) = "Well, let\'s end our talk for now. See you later. Bye."
1870   return phrases
1880 END FUNCTION
1890 REM  
1900 REM Returns an array of pairs of mutualy substitutable  
1910 REM TODO: Add type-specific suffixes where necessary! 
1920 FUNCTION setupReflexions() AS String(50,0 TO 1)
1930   REM TODO: add the respective type suffixes to your variable names if required 
1940   REM TODO: Check indexBase value (automatically generated) 
1950   LET indexBase = 0
1960   LET reflexions(0)(indexBase + 0) = " are "
1970   LET reflexions(0)(indexBase + 1) = " am "
1980   REM TODO: Check indexBase value (automatically generated) 
1990   LET indexBase = 0
2000   LET reflexions(1)(indexBase + 0) = " were "
2010   LET reflexions(1)(indexBase + 1) = " was "
2020   REM TODO: Check indexBase value (automatically generated) 
2030   LET indexBase = 0
2040   LET reflexions(2)(indexBase + 0) = " you "
2050   LET reflexions(2)(indexBase + 1) = " I "
2060   REM TODO: Check indexBase value (automatically generated) 
2070   LET indexBase = 0
2080   LET reflexions(3)(indexBase + 0) = " your"
2090   LET reflexions(3)(indexBase + 1) = " my"
2100   REM TODO: Check indexBase value (automatically generated) 
2110   LET indexBase = 0
2120   LET reflexions(4)(indexBase + 0) = " i\'ve "
2130   LET reflexions(4)(indexBase + 1) = " you\'ve "
2140   REM TODO: Check indexBase value (automatically generated) 
2150   LET indexBase = 0
2160   LET reflexions(5)(indexBase + 0) = " i\'m "
2170   LET reflexions(5)(indexBase + 1) = " you\'re "
2180   REM TODO: Check indexBase value (automatically generated) 
2190   LET indexBase = 0
2200   LET reflexions(6)(indexBase + 0) = " me "
2210   LET reflexions(6)(indexBase + 1) = " you "
2220   REM TODO: Check indexBase value (automatically generated) 
2230   LET indexBase = 0
2240   LET reflexions(7)(indexBase + 0) = " my "
2250   LET reflexions(7)(indexBase + 1) = " your "
2260   REM TODO: Check indexBase value (automatically generated) 
2270   LET indexBase = 0
2280   LET reflexions(8)(indexBase + 0) = " i "
2290   LET reflexions(8)(indexBase + 1) = " you "
2300   REM TODO: Check indexBase value (automatically generated) 
2310   LET indexBase = 0
2320   LET reflexions(9)(indexBase + 0) = " am "
2330   LET reflexions(9)(indexBase + 1) = " are "
2340   return reflexions
2350 END FUNCTION
2360 REM  
2370 REM This routine sets up the reply rings addressed by the key words defined in 
2380 REM routine `setupKeywords()´ and mapped hitherto by the cross table defined 
2390 REM in `setupMapping()´ 
2400 REM TODO: Add type-specific suffixes where necessary! 
2410 FUNCTION setupReplies() AS String(50,50)
2420   REM TODO: add the respective type suffixes to your variable names if required 
2430   REM We start with the highest index for performance reasons 
2440   REM (is to avoid frequent array resizing) 
2450   REM TODO: Check indexBase value (automatically generated) 
2460   LET indexBase = 0
2470   LET replies(29)(indexBase + 0) = "Say, do you have any psychological problems?"
2480   LET replies(29)(indexBase + 1) = "What does that suggest to you?"
2490   LET replies(29)(indexBase + 2) = "I see."
2500   LET replies(29)(indexBase + 3) = "I'm not sure I understand you fully."
2510   LET replies(29)(indexBase + 4) = "Come come elucidate your thoughts."
2520   LET replies(29)(indexBase + 5) = "Can you elaborate on that?"
2530   LET replies(29)(indexBase + 6) = "That is quite interesting."
2540   REM TODO: Check indexBase value (automatically generated) 
2550   LET indexBase = 0
2560   LET replies(0)(indexBase + 0) = "Don't you believe that I can*?"
2570   LET replies(0)(indexBase + 1) = "Perhaps you would like to be like me?"
2580   LET replies(0)(indexBase + 2) = "You want me to be able to*?"
2590   REM TODO: Check indexBase value (automatically generated) 
2600   LET indexBase = 0
2610   LET replies(1)(indexBase + 0) = "Perhaps you don't want to*?"
2620   LET replies(1)(indexBase + 1) = "Do you want to be able to*?"
2630   REM TODO: Check indexBase value (automatically generated) 
2640   LET indexBase = 0
2650   LET replies(2)(indexBase + 0) = "What makes you think I am*?"
2660   LET replies(2)(indexBase + 1) = "Does it please you to believe I am*?"
2670   LET replies(2)(indexBase + 2) = "Perhaps you would like to be*?"
2680   LET replies(2)(indexBase + 3) = "Do you sometimes wish you were*?"
2690   REM TODO: Check indexBase value (automatically generated) 
2700   LET indexBase = 0
2710   LET replies(3)(indexBase + 0) = "Don't you really*?"
2720   LET replies(3)(indexBase + 1) = "Why don't you*?"
2730   LET replies(3)(indexBase + 2) = "Do you wish to be able to*?"
2740   LET replies(3)(indexBase + 3) = "Does that trouble you*?"
2750   REM TODO: Check indexBase value (automatically generated) 
2760   LET indexBase = 0
2770   LET replies(4)(indexBase + 0) = "Do you often feel*?"
2780   LET replies(4)(indexBase + 1) = "Are you afraid of feeling*?"
2790   LET replies(4)(indexBase + 2) = "Do you enjoy feeling*?"
2800   REM TODO: Check indexBase value (automatically generated) 
2810   LET indexBase = 0
2820   LET replies(5)(indexBase + 0) = "Do you really believe I don't*?"
2830   LET replies(5)(indexBase + 1) = "Perhaps in good time I will*."
2840   LET replies(5)(indexBase + 2) = "Do you want me to*?"
2850   REM TODO: Check indexBase value (automatically generated) 
2860   LET indexBase = 0
2870   LET replies(6)(indexBase + 0) = "Do you think you should be able to*?"
2880   LET replies(6)(indexBase + 1) = "Why can't you*?"
2890   REM TODO: Check indexBase value (automatically generated) 
2900   LET indexBase = 0
2910   LET replies(7)(indexBase + 0) = "Why are you interested in whether or not I am*?"
2920   LET replies(7)(indexBase + 1) = "Would you prefer if I were not*?"
2930   LET replies(7)(indexBase + 2) = "Perhaps in your fantasies I am*?"
2940   REM TODO: Check indexBase value (automatically generated) 
2950   LET indexBase = 0
2960   LET replies(8)(indexBase + 0) = "How do you know you can't*?"
2970   LET replies(8)(indexBase + 1) = "Have you tried?"
2980   LET replies(8)(indexBase + 2) = "Perhaps you can now*."
2990   REM TODO: Check indexBase value (automatically generated) 
3000   LET indexBase = 0
3010   LET replies(9)(indexBase + 0) = "Did you come to me because you are*?"
3020   LET replies(9)(indexBase + 1) = "How long have you been*?"
3030   LET replies(9)(indexBase + 2) = "Do you believe it is normal to be*?"
3040   LET replies(9)(indexBase + 3) = "Do you enjoy being*?"
3050   REM TODO: Check indexBase value (automatically generated) 
3060   LET indexBase = 0
3070   LET replies(10)(indexBase + 0) = "We were discussing you--not me."
3080   LET replies(10)(indexBase + 1) = "Oh, I*."
3090   LET replies(10)(indexBase + 2) = "You're not really talking about me, are you?"
3100   REM TODO: Check indexBase value (automatically generated) 
3110   LET indexBase = 0
3120   LET replies(11)(indexBase + 0) = "What would it mean to you if you got*?"
3130   LET replies(11)(indexBase + 1) = "Why do you want*?"
3140   LET replies(11)(indexBase + 2) = "Suppose you soon got*..."
3150   LET replies(11)(indexBase + 3) = "What if you never got*?"
3160   LET replies(11)(indexBase + 4) = "I sometimes also want*."
3170   REM TODO: Check indexBase value (automatically generated) 
3180   LET indexBase = 0
3190   LET replies(12)(indexBase + 0) = "Why do you ask?"
3200   LET replies(12)(indexBase + 1) = "Does that question interest you?"
3210   LET replies(12)(indexBase + 2) = "What answer would please you the most?"
3220   LET replies(12)(indexBase + 3) = "What do you think?"
3230   LET replies(12)(indexBase + 4) = "Are such questions on your mind often?"
3240   LET replies(12)(indexBase + 5) = "What is it that you really want to know?"
3250   LET replies(12)(indexBase + 6) = "Have you asked anyone else?"
3260   LET replies(12)(indexBase + 7) = "Have you asked such questions before?"
3270   LET replies(12)(indexBase + 8) = "What else comes to mind when you ask that?"
3280   REM TODO: Check indexBase value (automatically generated) 
3290   LET indexBase = 0
3300   LET replies(13)(indexBase + 0) = "Names don't interest me."
3310   LET replies(13)(indexBase + 1) = "I don't care about names -- please go on."
3320   REM TODO: Check indexBase value (automatically generated) 
3330   LET indexBase = 0
3340   LET replies(14)(indexBase + 0) = "Is that the real reason?"
3350   LET replies(14)(indexBase + 1) = "Don't any other reasons come to mind?"
3360   LET replies(14)(indexBase + 2) = "Does that reason explain anything else?"
3370   LET replies(14)(indexBase + 3) = "What other reasons might there be?"
3380   REM TODO: Check indexBase value (automatically generated) 
3390   LET indexBase = 0
3400   LET replies(15)(indexBase + 0) = "Please don't apologize!"
3410   LET replies(15)(indexBase + 1) = "Apologies are not necessary."
3420   LET replies(15)(indexBase + 2) = "What feelings do you have when you apologize?"
3430   LET replies(15)(indexBase + 3) = "Don't be so defensive!"
3440   REM TODO: Check indexBase value (automatically generated) 
3450   LET indexBase = 0
3460   LET replies(16)(indexBase + 0) = "What does that dream suggest to you?"
3470   LET replies(16)(indexBase + 1) = "Do you dream often?"
3480   LET replies(16)(indexBase + 2) = "What persons appear in your dreams?"
3490   LET replies(16)(indexBase + 3) = "Are you disturbed by your dreams?"
3500   REM TODO: Check indexBase value (automatically generated) 
3510   LET indexBase = 0
3520   LET replies(17)(indexBase + 0) = "How do you do ...please state your problem."
3530   REM TODO: Check indexBase value (automatically generated) 
3540   LET indexBase = 0
3550   LET replies(18)(indexBase + 0) = "You don't seem quite certain."
3560   LET replies(18)(indexBase + 1) = "Why the uncertain tone?"
3570   LET replies(18)(indexBase + 2) = "Can't you be more positive?"
3580   LET replies(18)(indexBase + 3) = "You aren't sure?"
3590   LET replies(18)(indexBase + 4) = "Don't you know?"
3600   REM TODO: Check indexBase value (automatically generated) 
3610   LET indexBase = 0
3620   LET replies(19)(indexBase + 0) = "Are you saying no just to be negative?"
3630   LET replies(19)(indexBase + 1) = "You are being a bit negative."
3640   LET replies(19)(indexBase + 2) = "Why not?"
3650   LET replies(19)(indexBase + 3) = "Are you sure?"
3660   LET replies(19)(indexBase + 4) = "Why no?"
3670   REM TODO: Check indexBase value (automatically generated) 
3680   LET indexBase = 0
3690   LET replies(20)(indexBase + 0) = "Why are you concerned about my*?"
3700   LET replies(20)(indexBase + 1) = "What about your own*?"
3710   REM TODO: Check indexBase value (automatically generated) 
3720   LET indexBase = 0
3730   LET replies(21)(indexBase + 0) = "Can you think of a specific example?"
3740   LET replies(21)(indexBase + 1) = "When?"
3750   LET replies(21)(indexBase + 2) = "What are you thinking of?"
3760   LET replies(21)(indexBase + 3) = "Really, always?"
3770   REM TODO: Check indexBase value (automatically generated) 
3780   LET indexBase = 0
3790   LET replies(22)(indexBase + 0) = "Do you really think so?"
3800   LET replies(22)(indexBase + 1) = "But you are not sure you*?"
3810   LET replies(22)(indexBase + 2) = "Do you doubt you*?"
3820   REM TODO: Check indexBase value (automatically generated) 
3830   LET indexBase = 0
3840   LET replies(23)(indexBase + 0) = "In what way?"
3850   LET replies(23)(indexBase + 1) = "What resemblance do you see?"
3860   LET replies(23)(indexBase + 2) = "What does the similarity suggest to you?"
3870   LET replies(23)(indexBase + 3) = "What other connections do you see?"
3880   LET replies(23)(indexBase + 4) = "Could there really be some connection?"
3890   LET replies(23)(indexBase + 5) = "How?"
3900   LET replies(23)(indexBase + 6) = "You seem quite positive."
3910   REM TODO: Check indexBase value (automatically generated) 
3920   LET indexBase = 0
3930   LET replies(24)(indexBase + 0) = "Are you sure?"
3940   LET replies(24)(indexBase + 1) = "I see."
3950   LET replies(24)(indexBase + 2) = "I understand."
3960   REM TODO: Check indexBase value (automatically generated) 
3970   LET indexBase = 0
3980   LET replies(25)(indexBase + 0) = "Why do you bring up the topic of friends?"
3990   LET replies(25)(indexBase + 1) = "Do your friends worry you?"
4000   LET replies(25)(indexBase + 2) = "Do your friends pick on you?"
4010   LET replies(25)(indexBase + 3) = "Are you sure you have any friends?"
4020   LET replies(25)(indexBase + 4) = "Do you impose on your friends?"
4030   LET replies(25)(indexBase + 5) = "Perhaps your love for friends worries you."
4040   REM TODO: Check indexBase value (automatically generated) 
4050   LET indexBase = 0
4060   LET replies(26)(indexBase + 0) = "Do computers worry you?"
4070   LET replies(26)(indexBase + 1) = "Are you talking about me in particular?"
4080   LET replies(26)(indexBase + 2) = "Are you frightened by machines?"
4090   LET replies(26)(indexBase + 3) = "Why do you mention computers?"
4100   LET replies(26)(indexBase + 4) = "What do you think machines have to do with your problem?"
4110   LET replies(26)(indexBase + 5) = "Don't you think computers can help people?"
4120   LET replies(26)(indexBase + 6) = "What is it about machines that worries you?"
4130   REM TODO: Check indexBase value (automatically generated) 
4140   LET indexBase = 0
4150   LET replies(27)(indexBase + 0) = "Do you sometimes feel uneasy without a smartphone?"
4160   LET replies(27)(indexBase + 1) = "Have you had these phantasies before?"
4170   LET replies(27)(indexBase + 2) = "Does the world seem more real for you via apps?"
4180   REM TODO: Check indexBase value (automatically generated) 
4190   LET indexBase = 0
4200   LET replies(28)(indexBase + 0) = "Tell me more about your family."
4210   LET replies(28)(indexBase + 1) = "Who else in your family*?"
4220   LET replies(28)(indexBase + 2) = "What does family relations mean for you?"
4230   LET replies(28)(indexBase + 3) = "Come on, How old are you?"
4240   LET setupReplies = replies
4250   RETURN setupReplies
4260 END FUNCTION
4270 REM  
4280 REM Checks whether newInput has occurred among the recently cached 
4290 REM input strings in the histArray component of history and updates the history. 
4300 REM TODO: Add type-specific suffixes where necessary! 
4310 FUNCTION checkRepetition(history AS History, newInput AS String) AS boolean
4320   REM TODO: add the respective type suffixes to your variable names if required 
4330   LET hasOccurred = false
4340   IF length(newInput) > 4 THEN
4350     LET histDepth = length(history.histArray)
4360     FOR i = 0 TO histDepth-1
4370       IF newInput = history.histArray(i) THEN
4380         LET hasOccurred = true
4390       END IF
4400     NEXT i
4410     LET history.histArray(history.histIndex) = newInput
4420     LET history.histIndex = (history.histIndex + 1) % (histDepth)
4430   END IF
4440   return hasOccurred
4450 END FUNCTION
4460 REM  
4470 REM Looks for the occurrence of the first of the strings 
4480 REM contained in keywords within the given sentence (in 
4490 REM array order). 
4500 REM Returns an array of 
4510 REM 0: the index of the first identified keyword (if any, otherwise -1), 
4520 REM 1: the position inside sentence (0 if not found) 
4530 REM TODO: Add type-specific suffixes where necessary! 
4540 FUNCTION findKeyword(CONST keyMap AS KeyMapEntry(50), sentence AS String) AS integer(0 TO 1)
4550   REM TODO: add the respective type suffixes to your variable names if required 
4560   REM Contains the index of the keyword and its position in sentence 
4570   REM TODO: Check indexBase value (automatically generated) 
4580   LET indexBase = 0
4590   LET result(indexBase + 0) = -1
4600   LET result(indexBase + 1) = 0
4610   LET i = 0
4620   DO WHILE (result(0) < 0) AND (i < length(keyMap))
4630     LET var entry: KeyMapEntry = keyMap(i)
4640     LET position = pos(entry.keyword, sentence)
4650     IF position > 0 THEN
4660       LET result(0) = i
4670       LET result(1) = position
4680     END IF
4690     LET i = i+1
4700   LOOP
4710   RETURN result
4720 END FUNCTION
4730 REM  
4740 REM The lower the index the higher the rank of the keyword (search is sequential). 
4750 REM The index of the first keyword found in a user sentence maps to a respective 
4760 REM reply ring as defined in `setupReplies()´. 
4770 REM TODO: Add type-specific suffixes where necessary! 
4780 FUNCTION setupKeywords() AS KeyMapEntry(50)
4790   REM TODO: add the respective type suffixes to your variable names if required 
4800   REM The empty key string (last entry) is the default clause - will always be found 
4810   LET keywords(39).keyword = ""
4820   LET keywords(39).index = 29
4830   LET keywords(0).keyword = "can you "
4840   LET keywords(0).index = 0
4850   LET keywords(1).keyword = "can i "
4860   LET keywords(1).index = 1
4870   LET keywords(2).keyword = "you are "
4880   LET keywords(2).index = 2
4890   LET keywords(3).keyword = "you\'re "
4900   LET keywords(3).index = 2
4910   LET keywords(4).keyword = "i don't "
4920   LET keywords(4).index = 3
4930   LET keywords(5).keyword = "i feel "
4940   LET keywords(5).index = 4
4950   LET keywords(6).keyword = "why don\'t you "
4960   LET keywords(6).index = 5
4970   LET keywords(7).keyword = "why can\'t i "
4980   LET keywords(7).index = 6
4990   LET keywords(8).keyword = "are you "
5000   LET keywords(8).index = 7
5010   LET keywords(9).keyword = "i can\'t "
5020   LET keywords(9).index = 8
5030   LET keywords(10).keyword = "i am "
5040   LET keywords(10).index = 9
5050   LET keywords(11).keyword = "i\'m "
5060   LET keywords(11).index = 9
5070   LET keywords(12).keyword = "you "
5080   LET keywords(12).index = 10
5090   LET keywords(13).keyword = "i want "
5100   LET keywords(13).index = 11
5110   LET keywords(14).keyword = "what "
5120   LET keywords(14).index = 12
5130   LET keywords(15).keyword = "how "
5140   LET keywords(15).index = 12
5150   LET keywords(16).keyword = "who "
5160   LET keywords(16).index = 12
5170   LET keywords(17).keyword = "where "
5180   LET keywords(17).index = 12
5190   LET keywords(18).keyword = "when "
5200   LET keywords(18).index = 12
5210   LET keywords(19).keyword = "why "
5220   LET keywords(19).index = 12
5230   LET keywords(20).keyword = "name "
5240   LET keywords(20).index = 13
5250   LET keywords(21).keyword = "cause "
5260   LET keywords(21).index = 14
5270   LET keywords(22).keyword = "sorry "
5280   LET keywords(22).index = 15
5290   LET keywords(23).keyword = "dream "
5300   LET keywords(23).index = 16
5310   LET keywords(24).keyword = "hello "
5320   LET keywords(24).index = 17
5330   LET keywords(25).keyword = "hi "
5340   LET keywords(25).index = 17
5350   LET keywords(26).keyword = "maybe "
5360   LET keywords(26).index = 18
5370   LET keywords(27).keyword = " no"
5380   LET keywords(27).index = 19
5390   LET keywords(28).keyword = "your "
5400   LET keywords(28).index = 20
5410   LET keywords(29).keyword = "always "
5420   LET keywords(29).index = 21
5430   LET keywords(30).keyword = "think "
5440   LET keywords(30).index = 22
5450   LET keywords(31).keyword = "alike "
5460   LET keywords(31).index = 23
5470   LET keywords(32).keyword = "yes "
5480   LET keywords(32).index = 24
5490   LET keywords(33).keyword = "friend "
5500   LET keywords(33).index = 25
5510   LET keywords(34).keyword = "computer"
5520   LET keywords(34).index = 26
5530   LET keywords(35).keyword = "bot "
5540   LET keywords(35).index = 26
5550   LET keywords(36).keyword = "smartphone"
5560   LET keywords(36).index = 27
5570   LET keywords(37).keyword = "father "
5580   LET keywords(37).index = 28
5590   LET keywords(38).keyword = "mother "
5600   LET keywords(38).index = 28
5610   return keywords
5620 END FUNCTION
