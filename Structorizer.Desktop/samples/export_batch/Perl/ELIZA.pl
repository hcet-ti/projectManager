#!/usr/bin/perl
# Generated by Structorizer 3.32-10 

# Copyright (C) 2018-05-14 Kay Gürtzig 
# License: GPLv3-link 
# GNU General Public License (V 3) 
# https://www.gnu.org/licenses/gpl.html 
# http://www.gnu.de/documents/gpl.de.html 

use strict;
use warnings;
use Class::Struct;

# Cares for correct letter case among others 
sub adjustSpelling {
    my $sentence = $_[0];

    my $word;
    my $start;
    my $result;
    my $position;

    $result = $sentence;
    $position = 1;

    while ( ($position <= length($sentence)) && (copy($sentence, $position, 1) == " ") ) {
        $position = $position + 1;
    }


    if ( $position <= length($sentence) ) {
        $start = copy($sentence, 1, $position);
        delete($result, 1, $position);
        insert(uppercase($start), $result, 1);
    }


    my @array15d59179 = (" i ", " i\'")
    foreach $word (@array15d59179) {
        $position = pos($word, $result);

        while ( $position > 0 ) {
            delete($result, $position+1, 1);
            insert("I", $result, $position+1);
            $position = pos($word, $result);
        }

    }

    return $result;
}

# Checks whether the given text contains some kind of 
# good-bye phrase inducing the end of the conversation 
# and if so writes a correspding good-bye message and 
# returns true, otherwise false 
sub checkGoodBye {
    my $text = $_[0];
    my $phrases = $_[1];

    my $pair;


    foreach $pair (@$phrases) {

        if ( pos($pair[0], $text) > 0 ) {
            print $pair[1], "\n";
            return true;
        }

    }

    return false;
}

# Checks whether newInput has occurred among the recently cached 
# input strings in the histArray component of history and updates the history. 
sub checkRepetition {
    my $history = $_[0];
    my $newInput = $_[1];

    my $i;
    my $histDepth;
    my $hasOccurred;

    $hasOccurred = false;

    if ( length($newInput) > 4 ) {
        $histDepth = length($$history->histArray);

        for ($i = 0; $i <= $histDepth-1; $i += (1)) {

            if ( $newInput == $$history->histArray[$i] ) {
                $hasOccurred = true;
            }

        }

        $$history->histArray[$$history->histIndex] = $newInput;
        $$history->histIndex = ($$history->histIndex + 1) % ($histDepth);
    }

    return $hasOccurred;
}

sub conjugateStrings {
    my $sentence = $_[0];
    my $key = $_[1];
    my $keyPos = $_[2];
    my $flexions = $_[3];

    my $which;
    my $str;
    my $right;
    my $result;
    my $position;
    my $pos1;
    my $pos0;
    my $pair;
    my $left;

    $result = " " + copy($sentence, $keyPos + length($key), length($sentence)) + " ";

    foreach $pair (@$flexions) {
        $left = "";
        $right = $result;
        $pos0 = pos($pair[0], $right);
        $pos1 = pos($pair[1], $right);

        while ( $pos0 > 0 || $pos1 > 0 ) {
            # Detect which of the two words of the pair matches first (lest a substitution should be reverted) 
            $which = 0;
            $position = $pos0;

            if ( ($pos0 == 0) || (($pos1 > 0) && ($pos1 < $pos0)) ) {
                $which = 1;
                $position = $pos1;
            }

            $left = $left + copy($right, 1, $position-1) + $pair[1 - $which];
            $right = copy($right, $position + length($pair[$which]), length($right));
            $pos0 = pos($pair[0], $right);
            $pos1 = pos($pair[1], $right);
        }

        $result = $left + $right;
    }


    # Eliminate multiple spaces (replaced by single ones) and vertical bars 
    my @arraya3ac1257 = ("  ", "|")
    foreach $str (@arraya3ac1257) {
        $position = pos($str, $result);

        while ( $position > 0 ) {
            $result = copy($result, 1, $position-1) + copy($result, $position+1, length($result));
            $position = pos($str, $result);
        }

    }

    return $result;
}

# Looks for the occurrence of the first of the strings 
# contained in keywords within the given sentence (in 
# array order). 
# Returns an array of 
# 0: the index of the first identified keyword (if any, otherwise -1), 
# 1: the position inside sentence (0 if not found) 
sub findKeyword {
    my $keyMap = $_[0];
    my $sentence = $_[1];

    my @result;
    my $position;
    my $i;
    my $entry;

    # Contains the index of the keyword and its position in sentence 
    @result = (-1,0);
    $i = 0;

    while ( ($result[0] < 0) && ($i < length(@$keyMap)) ) {
        $entry = $$keyMap[$i];
        $position = pos($entry->keyword, $sentence);

        if ( $position > 0 ) {
            $result[0] = $i;
            $result[1] = $position;
        }

        $i = $i+1;
    }

    return $result;
}

# Converts the sentence to lowercase, eliminates all 
# interpunction (i.e. ',', '.', ';'), and pads the 
# sentence among blanks 
sub normalizeInput {
    my $sentence = $_[0];

    my $symbol;
    my $result;
    my $position;

    $sentence = lowercase($sentence);

    my @array7a266a97 = ('.', ',', ';', '!', '?')
    foreach $symbol (@array7a266a97) {
        $position = pos($symbol, $sentence);

        while ( $position > 0 ) {
            $sentence = copy($sentence, 1, $position-1) + copy($sentence, $position+1, length($sentence));
            $position = pos($symbol, $sentence);
        }

    }

    $result = " " + $sentence + " ";

    return $result;
}

sub setupGoodByePhrases {

    my @phrases;

    $phrases[0] = (" shut", "Okay. If you feel that way I\'ll shut up. ... Your choice.");
    $phrases[1] = ("bye", "Well, let\'s end our talk for now. See you later. Bye.");
    return @phrases;
}

# The lower the index the higher the rank of the keyword (search is sequential). 
# The index of the first keyword found in a user sentence maps to a respective 
# reply ring as defined in `setupReplies()´. 
sub setupKeywords {

    my @keywords;

    # The empty key string (last entry) is the default clause - will always be found 
    $keywords[39] = KeyMapEntry("", 29);
    $keywords[0] = KeyMapEntry("can you ", 0);
    $keywords[1] = KeyMapEntry("can i ", 1);
    $keywords[2] = KeyMapEntry("you are ", 2);
    $keywords[3] = KeyMapEntry("you\'re ", 2);
    $keywords[4] = KeyMapEntry("i don't ", 3);
    $keywords[5] = KeyMapEntry("i feel ", 4);
    $keywords[6] = KeyMapEntry("why don\'t you ", 5);
    $keywords[7] = KeyMapEntry("why can\'t i ", 6);
    $keywords[8] = KeyMapEntry("are you ", 7);
    $keywords[9] = KeyMapEntry("i can\'t ", 8);
    $keywords[10] = KeyMapEntry("i am ", 9);
    $keywords[11] = KeyMapEntry("i\'m ", 9);
    $keywords[12] = KeyMapEntry("you ", 10);
    $keywords[13] = KeyMapEntry("i want ", 11);
    $keywords[14] = KeyMapEntry("what ", 12);
    $keywords[15] = KeyMapEntry("how ", 12);
    $keywords[16] = KeyMapEntry("who ", 12);
    $keywords[17] = KeyMapEntry("where ", 12);
    $keywords[18] = KeyMapEntry("when ", 12);
    $keywords[19] = KeyMapEntry("why ", 12);
    $keywords[20] = KeyMapEntry("name ", 13);
    $keywords[21] = KeyMapEntry("cause ", 14);
    $keywords[22] = KeyMapEntry("sorry ", 15);
    $keywords[23] = KeyMapEntry("dream ", 16);
    $keywords[24] = KeyMapEntry("hello ", 17);
    $keywords[25] = KeyMapEntry("hi ", 17);
    $keywords[26] = KeyMapEntry("maybe ", 18);
    $keywords[27] = KeyMapEntry(" no", 19);
    $keywords[28] = KeyMapEntry("your ", 20);
    $keywords[29] = KeyMapEntry("always ", 21);
    $keywords[30] = KeyMapEntry("think ", 22);
    $keywords[31] = KeyMapEntry("alike ", 23);
    $keywords[32] = KeyMapEntry("yes ", 24);
    $keywords[33] = KeyMapEntry("friend ", 25);
    $keywords[34] = KeyMapEntry("computer", 26);
    $keywords[35] = KeyMapEntry("bot ", 26);
    $keywords[36] = KeyMapEntry("smartphone", 27);
    $keywords[37] = KeyMapEntry("father ", 28);
    $keywords[38] = KeyMapEntry("mother ", 28);
    return @keywords;
}

# Returns an array of pairs of mutually substitutable words 
# The second word may contain a '|' in order to prevent an inverse 
# replacement. 
sub setupReflexions {

    my @reflexions;

    $reflexions[0] = (" are ", " am ");
    # This is not always helpful (e.g. if it relates to things or third persons) 
    $reflexions[1] = (" were ", " was ");
    $reflexions[2] = (" you ", " i ");
    $reflexions[3] = (" yours ", " mine ");
    $reflexions[4] = (" yourself ", " myself ");
    $reflexions[5] = (" your ", " my ");
    $reflexions[6] = (" i\'ve ", " you\'ve ");
    $reflexions[7] = (" i\'m ", " you\'re ");
    # We must not replace "you" by "me", not in particular after "I" had been replaced by "you". 
    $reflexions[8] = (" me ", " |you ");
    return @reflexions;
}

# This routine sets up the reply rings addressed by the key words defined in 
# routine `setupKeywords()´ and mapped hitherto by the cross table defined 
# in `setupMapping()´ 
sub setupReplies {

    my @setupReplies;
    my @replies;

    # We start with the highest index for performance reasons 
    # (is to avoid frequent array resizing) 
    $replies[29] = ( "Say, do you have any psychological problems?", "What does that suggest to you?", "I see.", "I'm not sure I understand you fully.", "Come come elucidate your thoughts.", "Can you elaborate on that?", "That is quite interesting.");
    $replies[0] = ( "Don't you believe that I can*?", "Perhaps you would like to be like me?", "You want me to be able to*?");
    $replies[1] = ( "Perhaps you don't want to*?", "Do you want to be able to*?");
    $replies[2] = ( "What makes you think I am*?", "Does it please you to believe I am*?", "Perhaps you would like to be*?", "Do you sometimes wish you were*?");
    $replies[3] = ( "Don't you really*?", "Why don't you*?", "Do you wish to be able to*?", "Does that trouble you*?");
    $replies[4] = ( "Do you often feel*?", "Are you afraid of feeling*?", "Do you enjoy feeling*?");
    $replies[5] = ( "Do you really believe I don't*?", "Perhaps in good time I will*.", "Do you want me to*?");
    $replies[6] = ( "Do you think you should be able to*?", "Why can't you*?");
    $replies[7] = ( "Why are you interested in whether or not I am*?", "Would you prefer if I were not*?", "Perhaps in your fantasies I am*?");
    $replies[8] = ( "How do you know you can't*?", "Have you tried?","Perhaps you can now*.");
    $replies[9] = ( "Did you come to me because you are*?", "How long have you been*?", "Do you believe it is normal to be*?", "Do you enjoy being*?");
    $replies[10] = ( "We were discussing you--not me.", "Oh, I*.", "You're not really talking about me, are you?");
    $replies[11] = ( "What would it mean to you if you got*?", "Why do you want*?", "Suppose you soon got*...", "What if you never got*?", "I sometimes also want*.");
    $replies[12] = ( "Why do you ask?", "Does that question interest you?", "What answer would please you the most?", "What do you think?", "Are such questions on your mind often?", "What is it that you really want to know?", "Have you asked anyone else?", "Have you asked such questions before?", "What else comes to mind when you ask that?");
    $replies[13] = ( "Names don't interest me.", "I don't care about names -- please go on.");
    $replies[14] = ( "Is that the real reason?", "Don't any other reasons come to mind?", "Does that reason explain anything else?", "What other reasons might there be?");
    $replies[15] = ( "Please don't apologize!", "Apologies are not necessary.", "What feelings do you have when you apologize?", "Don't be so defensive!");
    $replies[16] = ( "What does that dream suggest to you?", "Do you dream often?", "What persons appear in your dreams?", "Are you disturbed by your dreams?");
    $replies[17] = ( "How do you do ...please state your problem.");
    $replies[18] = ( "You don't seem quite certain.", "Why the uncertain tone?", "Can't you be more positive?", "You aren't sure?", "Don't you know?");
    $replies[19] = ( "Are you saying no just to be negative?", "You are being a bit negative.", "Why not?", "Are you sure?", "Why no?");
    $replies[20] = ( "Why are you concerned about my*?", "What about your own*?");
    $replies[21] = ( "Can you think of a specific example?", "When?", "What are you thinking of?", "Really, always?");
    $replies[22] = ( "Do you really think so?", "But you are not sure you*?", "Do you doubt you*?");
    $replies[23] = ( "In what way?", "What resemblance do you see?", "What does the similarity suggest to you?", "What other connections do you see?", "Could there really be some connection?", "How?", "You seem quite positive.");
    $replies[24] = ( "Are you sure?", "I see.", "I understand.");
    $replies[25] = ( "Why do you bring up the topic of friends?", "Do your friends worry you?", "Do your friends pick on you?", "Are you sure you have any friends?", "Do you impose on your friends?", "Perhaps your love for friends worries you.");
    $replies[26] = ( "Do computers worry you?", "Are you talking about me in particular?", "Are you frightened by machines?", "Why do you mention computers?", "What do you think machines have to do with your problem?", "Don't you think computers can help people?", "What is it about machines that worries you?");
    $replies[27] = ( "Do you sometimes feel uneasy without a smartphone?", "Have you had these phantasies before?", "Does the world seem more real for you via apps?");
    $replies[28] = ( "Tell me more about your family.", "Who else in your family*?", "What does family relations mean for you?", "Come on, How old are you?");
    @setupReplies = @replies;

    return $setupReplies;
}

# = = = = 8< = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 

# Concept and lisp implementation published by Joseph Weizenbaum (MIT): 
# "ELIZA - A Computer Program For the Study of Natural Language Communication Between Man and Machine" - In: 
# Computational Linguistis 1(1966)9, pp. 36-45 
# Revision history: 
# 2016-10-06 Initial version 
# 2017-03-29 Two diagrams updated (comments translated to English) 
# 2017-03-29 More keywords and replies added 
# 2019-03-14 Replies and mapping reorganised for easier maintenance 
# 2019-03-15 key map joined from keyword array and index map 
# 2019-03-28 Keyword "bot" inserted (same reply ring as "computer") 
# 2019-11-28 New global type "History" (to ensure a homogenous array) 
# 2022-01-11 Measures against substition inversions a -> b -> a in conjugateStrings, reflexions revised. 

my $varPart;
my $userInput;
my $replyRing;
my $reply;
my @replies;
my @reflexions;
my $posAster;
my @offsets;
my @keyMap;
my $keyIndex;
my $isRepeated;
my $isGone;
my $history;
my @findInfo;
my $entry;
my @byePhrases;

# Title information 
print "************* ELIZA **************", "\n";
print "* Original design by J. Weizenbaum", "\n";
print "**********************************", "\n";
print "* Adapted for Basic on IBM PC by", "\n";
print "* - Patricia Danielson", "\n";
print "* - Paul Hashfield", "\n";
print "**********************************", "\n";
print "* Adapted for Structorizer by", "\n";
print "* - Kay Gürtzig / FH Erfurt 2016", "\n";
print "* Version: 2.4 (2022-01-11)", "\n";
print "* (Requires at least Structorizer 3.30-03 to run)", "\n";
print "**********************************", "\n";
# Stores the last five inputs of the user in a ring buffer, 
# the second component is the rolling (over-)write index. 
$history = History(("", "", "", "", ""), 0);
@replies = setupReplies();
@reflexions = setupReflexions();
@byePhrases = setupGoodByePhrases();
@keyMap = setupKeywords();
$offsets[length(@keyMap)-1] = 0;
$isGone = false;
# Starter 
print "Hi! I\'m your new therapist. My name is Eliza. What\'s your problem?", "\n";

do {
    chomp($userInput = <STDIN>);
    # Converts the input to lowercase, cuts out interpunctation 
    # and pads the string 
    $userInput = normalizeInput($userInput);
    $isGone = checkGoodBye($userInput, \@byePhrases);

    if ( ! $isGone ) {
        $reply = "Please don\'t repeat yourself!";
        $isRepeated = checkRepetition(\$history, $userInput);

        if ( ! $isRepeated ) {
            @findInfo = findKeyword(\@keyMap, $userInput);
            $keyIndex = $findInfo[0];

            if ( $keyIndex < 0 ) {
                # Should never happen... 
                $keyIndex = length(@keyMap)-1;
            }

            $entry = $keyMap[$keyIndex];
            # Variable part of the reply 
            $varPart = "";

            if ( length($entry->keyword) > 0 ) {
                $varPart = conjugateStrings($userInput, \$entry->keyword, $findInfo[1], \@reflexions);
            }

            $replyRing = $replies[$entry->index];
            $reply = $replyRing[$offsets[$keyIndex]];
            $offsets[$keyIndex] = ($offsets[$keyIndex] + 1) % length($replyRing);
            $posAster = pos("*", $reply);

            if ( $posAster > 0 ) {

                if ( $varPart == " " ) {
                    $reply = "You will have to elaborate more for me to help you.";
                }
                else {
                    delete($reply, $posAster, 1);
                    insert($varPart, $reply, $posAster);
                }

            }

            $reply = adjustSpelling($reply);
        }

        print $reply, "\n";
    }

} while (!( $isGone ));

