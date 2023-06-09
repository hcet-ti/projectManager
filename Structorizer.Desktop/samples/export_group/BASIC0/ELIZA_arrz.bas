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
120 REM 2022-01-11 Measures against substition inversions a -> b -> a in conjugateStrings, reflexions revised. 
130 REM Generated by Structorizer 3.32-06 
140 
150 REM Copyright (C) 2018-05-14 Kay Gürtzig 
160 REM License: GPLv3-link 
170 REM GNU General Public License (V 3) 
180 REM https://www.gnu.org/licenses/gpl.html 
190 REM http://www.gnu.de/documents/gpl.de.html 
200 
210 REM  
220 REM program ELIZA
230 REM TODO: add the respective type suffixes to your variable names if required 
240 REM Title information 
250 PRINT "************* ELIZA **************"
260 PRINT "* Original design by J. Weizenbaum"
270 PRINT "**********************************"
280 PRINT "* Adapted for Basic on IBM PC by"
290 PRINT "* - Patricia Danielson"
300 PRINT "* - Paul Hashfield"
310 PRINT "**********************************"
320 PRINT "* Adapted for Structorizer by"
330 PRINT "* - Kay Gürtzig / FH Erfurt 2016"
340 PRINT "* Version: 2.4 (2022-01-11)"
350 PRINT "* (Requires at least Structorizer 3.30-03 to run)"
360 PRINT "**********************************"
370 REM Stores the last five inputs of the user in a ring buffer, 
380 REM the second component is the rolling (over-)write index. 
390 DIM history AS History
400 LET history.histArray = {"", "", "", "", ""}
410 LET history.histIndex = 0
420 LET replies = setupReplies()
430 LET reflexions = setupReflexions()
440 LET byePhrases = setupGoodByePhrases()
450 LET keyMap = setupKeywords()
460 LET offsets(length(keyMap)-1) = 0
470 LET isGone = false
480 REM Starter 
490 PRINT "Hi! I\'m your new therapist. My name is Eliza. What\'s your problem?"
500 DO
510   INPUT userInput
520   REM Converts the input to lowercase, cuts out interpunctation 
530   REM and pads the string 
540   LET userInput = normalizeInput(userInput)
550   LET isGone = checkGoodBye(userInput, byePhrases)
560   IF NOT isGone THEN
570     LET reply = "Please don\'t repeat yourself!"
580     LET isRepeated = checkRepetition(history, userInput)
590     IF NOT isRepeated THEN
600       LET findInfo = findKeyword(keyMap, userInput)
610       LET keyIndex = findInfo(0)
620       IF keyIndex < 0 THEN
630         REM Should never happen... 
640         LET keyIndex = length(keyMap)-1
650       END IF
660       LET var entry: KeyMapEntry = keyMap(keyIndex)
670       REM Variable part of the reply 
680       LET varPart = ""
690       IF length(entry.keyword) > 0 THEN
700         LET varPart = conjugateStrings(userInput, entry.keyword, findInfo(1), reflexions)
710       END IF
720       LET replyRing = replies(entry.index)
730       LET reply = replyRing(offsets(keyIndex))
740       LET offsets(keyIndex) = (offsets(keyIndex) + 1) % length(replyRing)
750       LET posAster = pos("*", reply)
760       IF posAster > 0 THEN
770         IF varPart = " " THEN
780           LET reply = "You will have to elaborate more for me to help you."
790         ELSE
800           delete(reply, posAster, 1)
810           insert(varPart, reply, posAster)
820         END IF
830       END IF
840       LET reply = adjustSpelling(reply)
850     END IF
860     PRINT reply
870   END IF
880 LOOP UNTIL isGone
890 END
900 REM  
910 REM Cares for correct letter case among others 
920 REM TODO: Add type-specific suffixes where necessary! 
930 FUNCTION adjustSpelling(sentence AS String) AS String
940   REM TODO: add the respective type suffixes to your variable names if required 
950   LET result = sentence
960   LET position = 1
970   DO WHILE (position <= length(sentence)) AND (copy(sentence, position, 1) = " ")
980     LET position = position + 1
990   LOOP
1000   IF position <= length(sentence) THEN
1010     LET start = copy(sentence, 1, position)
1020     delete(result, 1, position)
1030     insert(uppercase(start), result, 1)
1040   END IF
1050   DIM arrayff31bf2c() AS String = {" i ", " i\'"}
1060   FOR EACH word IN arrayff31bf2c
1070     LET position = pos(word, result)
1080     DO WHILE position > 0
1090       delete(result, position+1, 1)
1100       insert("I", result, position+1)
1110       LET position = pos(word, result)
1120     LOOP
1130   NEXT word
1140   RETURN result
1150 END FUNCTION
1160 REM  
1170 REM Checks whether the given text contains some kind of 
1180 REM good-bye phrase inducing the end of the conversation 
1190 REM and if so writes a correspding good-bye message and 
1200 REM returns true, otherwise false 
1210 REM TODO: Add type-specific suffixes where necessary! 
1220 FUNCTION checkGoodBye(text AS String, phrases AS String(50,0 TO 1)) AS boolean
1230   REM TODO: add the respective type suffixes to your variable names if required 
1240   FOR EACH pair IN phrases
1250     IF pos(pair(0), text) > 0 THEN
1260       PRINT pair(1)
1270       RETURN true
1280     END IF
1290   NEXT pair
1300   return false
1310 END FUNCTION
1320 REM  
1330 REM TODO: Add type-specific suffixes where necessary! 
1340 FUNCTION conjugateStrings(sentence AS String, key AS String, keyPos AS integer, flexions AS String(50,0 TO 1)) AS String
1350   REM TODO: add the respective type suffixes to your variable names if required 
1360   LET result = " " + copy(sentence, keyPos + length(key), length(sentence)) + " "
1370   FOR EACH pair IN flexions
1380     LET left = ""
1390     LET right = result
1400     LET pos0 = pos(pair(0), right)
1410     LET pos1 = pos(pair(1), right)
1420     DO WHILE pos0 > 0 OR pos1 > 0
1430       REM Detect which of the two words of the pair matches first (lest a substitution should be reverted) 
1440       LET which = 0
1450       LET position = pos0
1460       IF (pos0 = 0) OR ((pos1 > 0) AND (pos1 < pos0)) THEN
1470         LET which = 1
1480         LET position = pos1
1490       END IF
1500       LET left = left + copy(right, 1, position-1) + pair(1 - which)
1510       LET right = copy(right, position + length(pair(which)), length(right))
1520       LET pos0 = pos(pair(0), right)
1530       LET pos1 = pos(pair(1), right)
1540     LOOP
1550     LET result = left + right
1560   NEXT pair
1570   REM Eliminate multiple spaces (replaced by single ones) and vertical bars 
1580   DIM array2a44329b() AS String = {"  ", "|"}
1590   FOR EACH str IN array2a44329b
1600     LET position = pos(str, result)
1610     DO WHILE position > 0
1620       LET result = copy(result, 1, position-1) + copy(result, position+1, length(result))
1630       LET position = pos(str, result)
1640     LOOP
1650   NEXT str
1660   RETURN result
1670 END FUNCTION
1680 REM  
1690 REM Converts the sentence to lowercase, eliminates all 
1700 REM interpunction (i.e. ',', '.', ';'), and pads the 
1710 REM sentence among blanks 
1720 REM TODO: Add type-specific suffixes where necessary! 
1730 FUNCTION normalizeInput(sentence AS String) AS String
1740   REM TODO: add the respective type suffixes to your variable names if required 
1750   LET sentence = lowercase(sentence)
1760   REM TODO: Specify an appropriate element type for the array! 
1770   DIM array1789d343() AS FIXME_1789d343 = {'.', ',', ';', '!', '?'}
1780   FOR EACH symbol IN array1789d343
1790     LET position = pos(symbol, sentence)
1800     DO WHILE position > 0
1810       LET sentence = copy(sentence, 1, position-1) + copy(sentence, position+1, length(sentence))
1820       LET position = pos(symbol, sentence)
1830     LOOP
1840   NEXT symbol
1850   LET result = " " + sentence + " "
1860   RETURN result
1870 END FUNCTION
1880 REM  
1890 REM TODO: Add type-specific suffixes where necessary! 
1900 FUNCTION setupGoodByePhrases() AS String(50,0 TO 1)
1910   REM TODO: add the respective type suffixes to your variable names if required 
1920   REM TODO: Check indexBase value (automatically generated) 
1930   LET indexBase = 0
1940   LET phrases(0)(indexBase + 0) = " shut"
1950   LET phrases(0)(indexBase + 1) = "Okay. If you feel that way I\'ll shut up. ... Your choice."
1960   REM TODO: Check indexBase value (automatically generated) 
1970   LET indexBase = 0
1980   LET phrases(1)(indexBase + 0) = "bye"
1990   LET phrases(1)(indexBase + 1) = "Well, let\'s end our talk for now. See you later. Bye."
2000   return phrases
2010 END FUNCTION
2020 REM  
2030 REM Returns an array of pairs of mutually substitutable words 
2040 REM The second word may contain a '|' in order to prevent an inverse 
2050 REM replacement. 
2060 REM TODO: Add type-specific suffixes where necessary! 
2070 FUNCTION setupReflexions() AS String(50,0 TO 1)
2080   REM TODO: add the respective type suffixes to your variable names if required 
2090   REM TODO: Check indexBase value (automatically generated) 
2100   LET indexBase = 0
2110   LET reflexions(0)(indexBase + 0) = " are "
2120   LET reflexions(0)(indexBase + 1) = " am "
2130   REM This is not always helpful (e.g. if it relates to things or third persons) 
2140   REM TODO: Check indexBase value (automatically generated) 
2150   LET indexBase = 0
2160   LET reflexions(1)(indexBase + 0) = " were "
2170   LET reflexions(1)(indexBase + 1) = " was "
2180   REM TODO: Check indexBase value (automatically generated) 
2190   LET indexBase = 0
2200   LET reflexions(2)(indexBase + 0) = " you "
2210   LET reflexions(2)(indexBase + 1) = " i "
2220   REM TODO: Check indexBase value (automatically generated) 
2230   LET indexBase = 0
2240   LET reflexions(3)(indexBase + 0) = " yours "
2250   LET reflexions(3)(indexBase + 1) = " mine "
2260   REM TODO: Check indexBase value (automatically generated) 
2270   LET indexBase = 0
2280   LET reflexions(4)(indexBase + 0) = " yourself "
2290   LET reflexions(4)(indexBase + 1) = " myself "
2300   REM TODO: Check indexBase value (automatically generated) 
2310   LET indexBase = 0
2320   LET reflexions(5)(indexBase + 0) = " your "
2330   LET reflexions(5)(indexBase + 1) = " my "
2340   REM TODO: Check indexBase value (automatically generated) 
2350   LET indexBase = 0
2360   LET reflexions(6)(indexBase + 0) = " i\'ve "
2370   LET reflexions(6)(indexBase + 1) = " you\'ve "
2380   REM TODO: Check indexBase value (automatically generated) 
2390   LET indexBase = 0
2400   LET reflexions(7)(indexBase + 0) = " i\'m "
2410   LET reflexions(7)(indexBase + 1) = " you\'re "
2420   REM We must not replace "you" by "me", not in particular after "I" had been replaced by "you". 
2430   REM TODO: Check indexBase value (automatically generated) 
2440   LET indexBase = 0
2450   LET reflexions(8)(indexBase + 0) = " me "
2460   LET reflexions(8)(indexBase + 1) = " |you "
2470   return reflexions
2480 END FUNCTION
2490 REM  
2500 REM This routine sets up the reply rings addressed by the key words defined in 
2510 REM routine `setupKeywords()´ and mapped hitherto by the cross table defined 
2520 REM in `setupMapping()´ 
2530 REM TODO: Add type-specific suffixes where necessary! 
2540 FUNCTION setupReplies() AS String(50,50)
2550   REM TODO: add the respective type suffixes to your variable names if required 
2560   REM We start with the highest index for performance reasons 
2570   REM (is to avoid frequent array resizing) 
2580   REM TODO: Check indexBase value (automatically generated) 
2590   LET indexBase = 0
2600   LET replies(29)(indexBase + 0) = "Say, do you have any psychological problems?"
2610   LET replies(29)(indexBase + 1) = "What does that suggest to you?"
2620   LET replies(29)(indexBase + 2) = "I see."
2630   LET replies(29)(indexBase + 3) = "I'm not sure I understand you fully."
2640   LET replies(29)(indexBase + 4) = "Come come elucidate your thoughts."
2650   LET replies(29)(indexBase + 5) = "Can you elaborate on that?"
2660   LET replies(29)(indexBase + 6) = "That is quite interesting."
2670   REM TODO: Check indexBase value (automatically generated) 
2680   LET indexBase = 0
2690   LET replies(0)(indexBase + 0) = "Don't you believe that I can*?"
2700   LET replies(0)(indexBase + 1) = "Perhaps you would like to be like me?"
2710   LET replies(0)(indexBase + 2) = "You want me to be able to*?"
2720   REM TODO: Check indexBase value (automatically generated) 
2730   LET indexBase = 0
2740   LET replies(1)(indexBase + 0) = "Perhaps you don't want to*?"
2750   LET replies(1)(indexBase + 1) = "Do you want to be able to*?"
2760   REM TODO: Check indexBase value (automatically generated) 
2770   LET indexBase = 0
2780   LET replies(2)(indexBase + 0) = "What makes you think I am*?"
2790   LET replies(2)(indexBase + 1) = "Does it please you to believe I am*?"
2800   LET replies(2)(indexBase + 2) = "Perhaps you would like to be*?"
2810   LET replies(2)(indexBase + 3) = "Do you sometimes wish you were*?"
2820   REM TODO: Check indexBase value (automatically generated) 
2830   LET indexBase = 0
2840   LET replies(3)(indexBase + 0) = "Don't you really*?"
2850   LET replies(3)(indexBase + 1) = "Why don't you*?"
2860   LET replies(3)(indexBase + 2) = "Do you wish to be able to*?"
2870   LET replies(3)(indexBase + 3) = "Does that trouble you*?"
2880   REM TODO: Check indexBase value (automatically generated) 
2890   LET indexBase = 0
2900   LET replies(4)(indexBase + 0) = "Do you often feel*?"
2910   LET replies(4)(indexBase + 1) = "Are you afraid of feeling*?"
2920   LET replies(4)(indexBase + 2) = "Do you enjoy feeling*?"
2930   REM TODO: Check indexBase value (automatically generated) 
2940   LET indexBase = 0
2950   LET replies(5)(indexBase + 0) = "Do you really believe I don't*?"
2960   LET replies(5)(indexBase + 1) = "Perhaps in good time I will*."
2970   LET replies(5)(indexBase + 2) = "Do you want me to*?"
2980   REM TODO: Check indexBase value (automatically generated) 
2990   LET indexBase = 0
3000   LET replies(6)(indexBase + 0) = "Do you think you should be able to*?"
3010   LET replies(6)(indexBase + 1) = "Why can't you*?"
3020   REM TODO: Check indexBase value (automatically generated) 
3030   LET indexBase = 0
3040   LET replies(7)(indexBase + 0) = "Why are you interested in whether or not I am*?"
3050   LET replies(7)(indexBase + 1) = "Would you prefer if I were not*?"
3060   LET replies(7)(indexBase + 2) = "Perhaps in your fantasies I am*?"
3070   REM TODO: Check indexBase value (automatically generated) 
3080   LET indexBase = 0
3090   LET replies(8)(indexBase + 0) = "How do you know you can't*?"
3100   LET replies(8)(indexBase + 1) = "Have you tried?"
3110   LET replies(8)(indexBase + 2) = "Perhaps you can now*."
3120   REM TODO: Check indexBase value (automatically generated) 
3130   LET indexBase = 0
3140   LET replies(9)(indexBase + 0) = "Did you come to me because you are*?"
3150   LET replies(9)(indexBase + 1) = "How long have you been*?"
3160   LET replies(9)(indexBase + 2) = "Do you believe it is normal to be*?"
3170   LET replies(9)(indexBase + 3) = "Do you enjoy being*?"
3180   REM TODO: Check indexBase value (automatically generated) 
3190   LET indexBase = 0
3200   LET replies(10)(indexBase + 0) = "We were discussing you--not me."
3210   LET replies(10)(indexBase + 1) = "Oh, I*."
3220   LET replies(10)(indexBase + 2) = "You're not really talking about me, are you?"
3230   REM TODO: Check indexBase value (automatically generated) 
3240   LET indexBase = 0
3250   LET replies(11)(indexBase + 0) = "What would it mean to you if you got*?"
3260   LET replies(11)(indexBase + 1) = "Why do you want*?"
3270   LET replies(11)(indexBase + 2) = "Suppose you soon got*..."
3280   LET replies(11)(indexBase + 3) = "What if you never got*?"
3290   LET replies(11)(indexBase + 4) = "I sometimes also want*."
3300   REM TODO: Check indexBase value (automatically generated) 
3310   LET indexBase = 0
3320   LET replies(12)(indexBase + 0) = "Why do you ask?"
3330   LET replies(12)(indexBase + 1) = "Does that question interest you?"
3340   LET replies(12)(indexBase + 2) = "What answer would please you the most?"
3350   LET replies(12)(indexBase + 3) = "What do you think?"
3360   LET replies(12)(indexBase + 4) = "Are such questions on your mind often?"
3370   LET replies(12)(indexBase + 5) = "What is it that you really want to know?"
3380   LET replies(12)(indexBase + 6) = "Have you asked anyone else?"
3390   LET replies(12)(indexBase + 7) = "Have you asked such questions before?"
3400   LET replies(12)(indexBase + 8) = "What else comes to mind when you ask that?"
3410   REM TODO: Check indexBase value (automatically generated) 
3420   LET indexBase = 0
3430   LET replies(13)(indexBase + 0) = "Names don't interest me."
3440   LET replies(13)(indexBase + 1) = "I don't care about names -- please go on."
3450   REM TODO: Check indexBase value (automatically generated) 
3460   LET indexBase = 0
3470   LET replies(14)(indexBase + 0) = "Is that the real reason?"
3480   LET replies(14)(indexBase + 1) = "Don't any other reasons come to mind?"
3490   LET replies(14)(indexBase + 2) = "Does that reason explain anything else?"
3500   LET replies(14)(indexBase + 3) = "What other reasons might there be?"
3510   REM TODO: Check indexBase value (automatically generated) 
3520   LET indexBase = 0
3530   LET replies(15)(indexBase + 0) = "Please don't apologize!"
3540   LET replies(15)(indexBase + 1) = "Apologies are not necessary."
3550   LET replies(15)(indexBase + 2) = "What feelings do you have when you apologize?"
3560   LET replies(15)(indexBase + 3) = "Don't be so defensive!"
3570   REM TODO: Check indexBase value (automatically generated) 
3580   LET indexBase = 0
3590   LET replies(16)(indexBase + 0) = "What does that dream suggest to you?"
3600   LET replies(16)(indexBase + 1) = "Do you dream often?"
3610   LET replies(16)(indexBase + 2) = "What persons appear in your dreams?"
3620   LET replies(16)(indexBase + 3) = "Are you disturbed by your dreams?"
3630   REM TODO: Check indexBase value (automatically generated) 
3640   LET indexBase = 0
3650   LET replies(17)(indexBase + 0) = "How do you do ...please state your problem."
3660   REM TODO: Check indexBase value (automatically generated) 
3670   LET indexBase = 0
3680   LET replies(18)(indexBase + 0) = "You don't seem quite certain."
3690   LET replies(18)(indexBase + 1) = "Why the uncertain tone?"
3700   LET replies(18)(indexBase + 2) = "Can't you be more positive?"
3710   LET replies(18)(indexBase + 3) = "You aren't sure?"
3720   LET replies(18)(indexBase + 4) = "Don't you know?"
3730   REM TODO: Check indexBase value (automatically generated) 
3740   LET indexBase = 0
3750   LET replies(19)(indexBase + 0) = "Are you saying no just to be negative?"
3760   LET replies(19)(indexBase + 1) = "You are being a bit negative."
3770   LET replies(19)(indexBase + 2) = "Why not?"
3780   LET replies(19)(indexBase + 3) = "Are you sure?"
3790   LET replies(19)(indexBase + 4) = "Why no?"
3800   REM TODO: Check indexBase value (automatically generated) 
3810   LET indexBase = 0
3820   LET replies(20)(indexBase + 0) = "Why are you concerned about my*?"
3830   LET replies(20)(indexBase + 1) = "What about your own*?"
3840   REM TODO: Check indexBase value (automatically generated) 
3850   LET indexBase = 0
3860   LET replies(21)(indexBase + 0) = "Can you think of a specific example?"
3870   LET replies(21)(indexBase + 1) = "When?"
3880   LET replies(21)(indexBase + 2) = "What are you thinking of?"
3890   LET replies(21)(indexBase + 3) = "Really, always?"
3900   REM TODO: Check indexBase value (automatically generated) 
3910   LET indexBase = 0
3920   LET replies(22)(indexBase + 0) = "Do you really think so?"
3930   LET replies(22)(indexBase + 1) = "But you are not sure you*?"
3940   LET replies(22)(indexBase + 2) = "Do you doubt you*?"
3950   REM TODO: Check indexBase value (automatically generated) 
3960   LET indexBase = 0
3970   LET replies(23)(indexBase + 0) = "In what way?"
3980   LET replies(23)(indexBase + 1) = "What resemblance do you see?"
3990   LET replies(23)(indexBase + 2) = "What does the similarity suggest to you?"
4000   LET replies(23)(indexBase + 3) = "What other connections do you see?"
4010   LET replies(23)(indexBase + 4) = "Could there really be some connection?"
4020   LET replies(23)(indexBase + 5) = "How?"
4030   LET replies(23)(indexBase + 6) = "You seem quite positive."
4040   REM TODO: Check indexBase value (automatically generated) 
4050   LET indexBase = 0
4060   LET replies(24)(indexBase + 0) = "Are you sure?"
4070   LET replies(24)(indexBase + 1) = "I see."
4080   LET replies(24)(indexBase + 2) = "I understand."
4090   REM TODO: Check indexBase value (automatically generated) 
4100   LET indexBase = 0
4110   LET replies(25)(indexBase + 0) = "Why do you bring up the topic of friends?"
4120   LET replies(25)(indexBase + 1) = "Do your friends worry you?"
4130   LET replies(25)(indexBase + 2) = "Do your friends pick on you?"
4140   LET replies(25)(indexBase + 3) = "Are you sure you have any friends?"
4150   LET replies(25)(indexBase + 4) = "Do you impose on your friends?"
4160   LET replies(25)(indexBase + 5) = "Perhaps your love for friends worries you."
4170   REM TODO: Check indexBase value (automatically generated) 
4180   LET indexBase = 0
4190   LET replies(26)(indexBase + 0) = "Do computers worry you?"
4200   LET replies(26)(indexBase + 1) = "Are you talking about me in particular?"
4210   LET replies(26)(indexBase + 2) = "Are you frightened by machines?"
4220   LET replies(26)(indexBase + 3) = "Why do you mention computers?"
4230   LET replies(26)(indexBase + 4) = "What do you think machines have to do with your problem?"
4240   LET replies(26)(indexBase + 5) = "Don't you think computers can help people?"
4250   LET replies(26)(indexBase + 6) = "What is it about machines that worries you?"
4260   REM TODO: Check indexBase value (automatically generated) 
4270   LET indexBase = 0
4280   LET replies(27)(indexBase + 0) = "Do you sometimes feel uneasy without a smartphone?"
4290   LET replies(27)(indexBase + 1) = "Have you had these phantasies before?"
4300   LET replies(27)(indexBase + 2) = "Does the world seem more real for you via apps?"
4310   REM TODO: Check indexBase value (automatically generated) 
4320   LET indexBase = 0
4330   LET replies(28)(indexBase + 0) = "Tell me more about your family."
4340   LET replies(28)(indexBase + 1) = "Who else in your family*?"
4350   LET replies(28)(indexBase + 2) = "What does family relations mean for you?"
4360   LET replies(28)(indexBase + 3) = "Come on, How old are you?"
4370   LET setupReplies = replies
4380   RETURN setupReplies
4390 END FUNCTION
4400 REM  
4410 REM Checks whether newInput has occurred among the recently cached 
4420 REM input strings in the histArray component of history and updates the history. 
4430 REM TODO: Add type-specific suffixes where necessary! 
4440 FUNCTION checkRepetition(history AS History, newInput AS String) AS boolean
4450   REM TODO: add the respective type suffixes to your variable names if required 
4460   LET hasOccurred = false
4470   IF length(newInput) > 4 THEN
4480     LET histDepth = length(history.histArray)
4490     FOR i = 0 TO histDepth-1
4500       IF newInput = history.histArray(i) THEN
4510         LET hasOccurred = true
4520       END IF
4530     NEXT i
4540     LET history.histArray(history.histIndex) = newInput
4550     LET history.histIndex = (history.histIndex + 1) % (histDepth)
4560   END IF
4570   return hasOccurred
4580 END FUNCTION
4590 REM  
4600 REM Looks for the occurrence of the first of the strings 
4610 REM contained in keywords within the given sentence (in 
4620 REM array order). 
4630 REM Returns an array of 
4640 REM 0: the index of the first identified keyword (if any, otherwise -1), 
4650 REM 1: the position inside sentence (0 if not found) 
4660 REM TODO: Add type-specific suffixes where necessary! 
4670 FUNCTION findKeyword(CONST keyMap AS KeyMapEntry(50), sentence AS String) AS integer(0 TO 1)
4680   REM TODO: add the respective type suffixes to your variable names if required 
4690   REM Contains the index of the keyword and its position in sentence 
4700   REM TODO: Check indexBase value (automatically generated) 
4710   LET indexBase = 0
4720   LET result(indexBase + 0) = -1
4730   LET result(indexBase + 1) = 0
4740   LET i = 0
4750   DO WHILE (result(0) < 0) AND (i < length(keyMap))
4760     LET var entry: KeyMapEntry = keyMap(i)
4770     LET position = pos(entry.keyword, sentence)
4780     IF position > 0 THEN
4790       LET result(0) = i
4800       LET result(1) = position
4810     END IF
4820     LET i = i+1
4830   LOOP
4840   RETURN result
4850 END FUNCTION
4860 REM  
4870 REM The lower the index the higher the rank of the keyword (search is sequential). 
4880 REM The index of the first keyword found in a user sentence maps to a respective 
4890 REM reply ring as defined in `setupReplies()´. 
4900 REM TODO: Add type-specific suffixes where necessary! 
4910 FUNCTION setupKeywords() AS KeyMapEntry(50)
4920   REM TODO: add the respective type suffixes to your variable names if required 
4930   REM The empty key string (last entry) is the default clause - will always be found 
4940   LET keywords(39).keyword = ""
4950   LET keywords(39).index = 29
4960   LET keywords(0).keyword = "can you "
4970   LET keywords(0).index = 0
4980   LET keywords(1).keyword = "can i "
4990   LET keywords(1).index = 1
5000   LET keywords(2).keyword = "you are "
5010   LET keywords(2).index = 2
5020   LET keywords(3).keyword = "you\'re "
5030   LET keywords(3).index = 2
5040   LET keywords(4).keyword = "i don't "
5050   LET keywords(4).index = 3
5060   LET keywords(5).keyword = "i feel "
5070   LET keywords(5).index = 4
5080   LET keywords(6).keyword = "why don\'t you "
5090   LET keywords(6).index = 5
5100   LET keywords(7).keyword = "why can\'t i "
5110   LET keywords(7).index = 6
5120   LET keywords(8).keyword = "are you "
5130   LET keywords(8).index = 7
5140   LET keywords(9).keyword = "i can\'t "
5150   LET keywords(9).index = 8
5160   LET keywords(10).keyword = "i am "
5170   LET keywords(10).index = 9
5180   LET keywords(11).keyword = "i\'m "
5190   LET keywords(11).index = 9
5200   LET keywords(12).keyword = "you "
5210   LET keywords(12).index = 10
5220   LET keywords(13).keyword = "i want "
5230   LET keywords(13).index = 11
5240   LET keywords(14).keyword = "what "
5250   LET keywords(14).index = 12
5260   LET keywords(15).keyword = "how "
5270   LET keywords(15).index = 12
5280   LET keywords(16).keyword = "who "
5290   LET keywords(16).index = 12
5300   LET keywords(17).keyword = "where "
5310   LET keywords(17).index = 12
5320   LET keywords(18).keyword = "when "
5330   LET keywords(18).index = 12
5340   LET keywords(19).keyword = "why "
5350   LET keywords(19).index = 12
5360   LET keywords(20).keyword = "name "
5370   LET keywords(20).index = 13
5380   LET keywords(21).keyword = "cause "
5390   LET keywords(21).index = 14
5400   LET keywords(22).keyword = "sorry "
5410   LET keywords(22).index = 15
5420   LET keywords(23).keyword = "dream "
5430   LET keywords(23).index = 16
5440   LET keywords(24).keyword = "hello "
5450   LET keywords(24).index = 17
5460   LET keywords(25).keyword = "hi "
5470   LET keywords(25).index = 17
5480   LET keywords(26).keyword = "maybe "
5490   LET keywords(26).index = 18
5500   LET keywords(27).keyword = " no"
5510   LET keywords(27).index = 19
5520   LET keywords(28).keyword = "your "
5530   LET keywords(28).index = 20
5540   LET keywords(29).keyword = "always "
5550   LET keywords(29).index = 21
5560   LET keywords(30).keyword = "think "
5570   LET keywords(30).index = 22
5580   LET keywords(31).keyword = "alike "
5590   LET keywords(31).index = 23
5600   LET keywords(32).keyword = "yes "
5610   LET keywords(32).index = 24
5620   LET keywords(33).keyword = "friend "
5630   LET keywords(33).index = 25
5640   LET keywords(34).keyword = "computer"
5650   LET keywords(34).index = 26
5660   LET keywords(35).keyword = "bot "
5670   LET keywords(35).index = 26
5680   LET keywords(36).keyword = "smartphone"
5690   LET keywords(36).index = 27
5700   LET keywords(37).keyword = "father "
5710   LET keywords(37).index = 28
5720   LET keywords(38).keyword = "mother "
5730   LET keywords(38).index = 28
5740   return keywords
5750 END FUNCTION
