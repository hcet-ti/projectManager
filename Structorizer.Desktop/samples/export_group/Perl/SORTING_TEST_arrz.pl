#!/usr/bin/perl
# Generated by Structorizer 3.32-01 

# Copyright (C) 2019-10-02 Kay Gürtzig 
# License: GPLv3-link 
# GNU General Public License (V 3) 
# https://www.gnu.org/licenses/gpl.html 
# http://www.gnu.de/documents/gpl.de.html 

use strict;
use warnings;
use Class::Struct;
use threads;
use threads::shared;

# Implements the well-known BubbleSort algorithm. 
# Compares neigbouring elements and swaps them in case of an inversion. 
# Repeats this while inversions have been found. After every 
# loop passage at least one element (the largest one out of the 
# processed subrange) finds its final place at the end of the 
# subrange. 
sub bubbleSort {
    my $values = $_[0];

    my $temp;
    my $posSwapped;
    my $i;
    my $ende;

    $ende = length(@$values) - 2;

    do {
        # The index of the most recent swapping (-1 means no swapping done). 
        $posSwapped = -1;

        for ($i = 0; $i <= $ende; $i += (1)) {

            if ( $$values[$i] > $$values[$i+1] ) {
                $temp = $$values[$i];
                $$values[$i] = $$values[$i+1];
                $$values[$i+1] = $temp;
                $posSwapped = $i;
            }

        }

        $ende = $posSwapped - 1;
    } while (!( $posSwapped < 0 ));

}

# Given a max-heap 'heap´ with element at index 'i´ possibly 
# violating the heap property wrt. its subtree upto and including 
# index range-1, restores heap property in the subtree at index i 
# again. 
sub maxHeapify {
    my $heap = $_[0];
    my $i = $_[1];
    my $range = $_[2];

    my $temp;
    my $right;
    my $max;
    my $left;

    # Indices of left and right child of node i 
    $right = ($i+1) * 2;
    $left = $right - 1;
    # Index of the (local) maximum 
    $max = $i;

    if ( $left < $range && $$heap[$left] > $$heap[$i] ) {
        $max = $left;
    }


    if ( $right < $range && $$heap[$right] > $$heap[$max] ) {
        $max = $right;
    }


    if ( $max != $i ) {
        $temp = $$heap[$i];
        $$heap[$i] = $$heap[$max];
        $$heap[$max] = $temp;
        maxHeapify(\@$heap, $max, $range);
    }

}

# Partitions array 'values´ between indices 'start´ und 'stop´-1 with 
# respect to the pivot element initially at index 'p´ into smaller 
# and greater elements. 
# Returns the new (and final) index of the pivot element (which 
# separates the sequence of smaller elements from the sequence 
# of greater elements). 
# This is not the most efficient algorithm (about half the swapping 
# might still be avoided) but it is pretty clear. 
sub partition {
    my $values = $_[0];
    my $start = $_[1];
    my $stop = $_[2];
    my $p = $_[3];

    my $seen;
    my $pivot;

    # Cache the pivot element 
    $pivot = $$values[$p];
    # Exchange the pivot element with the start element 
    $$values[$p] = $$values[$start];
    $$values[$start] = $pivot;
    $p = $start;
    # Beginning and end of the remaining undiscovered range 
    $start = $start + 1;
    $stop = $stop - 1;

    # Still unseen elements? 
    # Loop invariants: 
    # 1. p = start - 1 
    # 2. pivot = values[p] 
    # 3. i < start → values[i] ≤ pivot 
    # 4. stop < i → pivot < values[i] 
    while ( $start <= $stop ) {
        # Fetch the first element of the undiscovered area 
        $seen = $$values[$start];

        # Does the checked element belong to the smaller area? 
        if ( $seen <= $pivot ) {
            # Insert the seen element between smaller area and pivot element 
            $$values[$p] = $seen;
            $$values[$start] = $pivot;
            # Shift the border between lower and undicovered area, 
            # update pivot position. 
            $p = $p + 1;
            $start = $start + 1;
        }
        else {
            # Insert the checked element between undiscovered and larger area 
            $$values[$start] = $$values[$stop];
            $$values[$stop] = $seen;
            # Shift the border between undiscovered and larger area 
            $stop = $stop - 1;
        }

    }

    return $p;
}

# Checks whether or not the passed-in array is (ascendingly) sorted. 
sub testSorted {
    my $numbers = $_[0];

    my $isSorted;
    my $i;

    $isSorted = true;
    $i = 0;

    # As we compare with the following element, we must stop at the penultimate index 
    while ( $isSorted && ($i <= length($numbers)-2) ) {

        # Is there an inversion? 
        if ( $numbers[$i] > $numbers[$i+1] ) {
            $isSorted = false;
        }
        else {
            $i = $i + 1;
        }

    }

    return $isSorted;
}

# Runs through the array heap and converts it to a max-heap 
# in a bottom-up manner, i.e. starts above the "leaf" level 
# (index >= length(heap) div 2) and goes then up towards 
# the root. 
sub buildMaxHeap {
    my $heap = $_[0];

    my $lgth;
    my $k;

    $lgth = length($heap);

    for ($k = $lgth / 2 - 1; $k >= 0; $k += (-1)) {
        maxHeapify($heap, $k, $lgth);
    }

}

# Recursively sorts a subrange of the given array 'values´.  
# start is the first index of the subsequence to be sorted, 
# stop is the index BEHIND the subsequence to be sorted. 
sub quickSort {
    my $values = $_[0];
    my $start = $_[1];
    my $stop = $_[2];

    my $p;


    # At least 2 elements? (Less don't make sense.) 
    if ( $stop >= $start + 2 ) {
        # Select a pivot element, be p its index. 
        # (here: randomly chosen element out of start ... stop-1) 
        $p = rand($stop-$start) + $start;
        # Partition the array into smaller and greater elements 
        # Get the resulting (and final) position of the pivot element 
        $p = partition($values, $start, $stop, $p);
        # Sort subsequances separately and independently ... 

        # ========================================================== 
        # ================= START PARALLEL SECTION ================= 
        # ========================================================== 
        # Requires at least Perl 5.8 and version threads 2.07 
        {

            # ----------------- START THREAD 0 ----------------- 
            my $thr98a2d384_0 = threads->create(sub {
                my $values = $_[0];
                my $start = $_[1];
                my $p = $_[2];
                # Sort left (lower) array part 
                quickSort($values, $start, $p);
            }, ($values, $start, $p));


            # ----------------- START THREAD 1 ----------------- 
            my $thr98a2d384_1 = threads->create(sub {
                my $values = $_[0];
                my $p = $_[1];
                my $stop = $_[2];
                # Sort right (higher) array part 
                quickSort($values, $p+1, $stop);
            }, ($values, $p, $stop));


            # ----------------- AWAIT THREAD 0 ----------------- 
            $thr98a2d384_0->join();


            # ----------------- AWAIT THREAD 1 ----------------- 
            $thr98a2d384_1->join();

        }
        # ========================================================== 
        # ================== END PARALLEL SECTION ================== 
        # ========================================================== 

    }

}

# Sorts the array 'values´ of numbers according to he heap sort 
# algorithm 
sub heapSort {
    my $values = $_[0];

    my $maximum;
    my $k;
    my $heapRange;

    buildMaxHeap(\@$values);
    $heapRange = length(@$values);

    for ($k = $heapRange - 1; $k >= 1; $k += (-1)) {
        $heapRange = $heapRange - 1;
        # Swap the maximum value (root of the heap) to the heap end 
        $maximum = $$values[0];
        $$values[0] = $$values[$heapRange];
        $$values[$heapRange] = $maximum;
        maxHeapify(\@$values, 0, $heapRange);
    }

}
# Creates three equal arrays of numbers and has them sorted with different sorting algorithms 
# to allow performance comparison via execution counting ("Collect Runtime Data" should 
# sensibly be switched on). 
# Requested input data are: Number of elements (size) and filing mode. 

my @values3;
my @values2;
my @values1;
my $show;
my $ok3;
my $ok2;
my $ok1;
my $modus;
my $i;
my $elementCount;


do {
    chomp($elementCount = <STDIN>);
} while (!( $elementCount >= 1 ));


do {
    print "Filling: 1 = random, 2 = increasing, 3 = decreasing"; chomp($modus = <STDIN>);
} while (!( $modus == 1 || $modus == 2 || $modus == 3 ));


for ($i = 0; $i <= $elementCount-1; $i += (1)) {

    switch ( $modus ) {

        case (1) {
            $values1[$i] = rand(10000);
        }

        case (2) {
            $values1[$i] = $i;
        }

        case (3) {
            $values1[$i] = -$i;
        }
    }

}


# Copy the array for exact comparability 
for ($i = 0; $i <= $elementCount-1; $i += (1)) {
    $values2[$i] = $values1[$i];
    $values3[$i] = $values1[$i];
}


# ========================================================== 
# ================= START PARALLEL SECTION ================= 
# ========================================================== 
# Requires at least Perl 5.8 and version threads 2.07 
{

    # ----------------- START THREAD 0 ----------------- 
    my $thr465fbb06_0 = threads->create(sub {
        my $values1 = $_[0];
        bubbleSort(\@values1);
    }, (\@values1));


    # ----------------- START THREAD 1 ----------------- 
    my $thr465fbb06_1 = threads->create(sub {
        my $values2 = $_[0];
        my $elementCount = $_[1];
        quickSort(\@values2, 0, $elementCount);
    }, (\@values2, $elementCount));


    # ----------------- START THREAD 2 ----------------- 
    my $thr465fbb06_2 = threads->create(sub {
        my $values3 = $_[0];
        heapSort(\@values3);
    }, (\@values3));


    # ----------------- AWAIT THREAD 0 ----------------- 
    $thr465fbb06_0->join();


    # ----------------- AWAIT THREAD 1 ----------------- 
    $thr465fbb06_1->join();


    # ----------------- AWAIT THREAD 2 ----------------- 
    $thr465fbb06_2->join();

}
# ========================================================== 
# ================== END PARALLEL SECTION ================== 
# ========================================================== 

$ok1 = testSorted(\@values1);
$ok2 = testSorted(\@values2);
$ok3 = testSorted(\@values3);

if ( ! $ok1 || ! $ok2 || ! $ok3 ) {

    for ($i = 0; $i <= $elementCount-1; $i += (1)) {

        if ( $values1[$i] != $values2[$i] || $values1[$i] != $values3[$i] ) {
            print "Difference at [", $i, "]: ", $values1[$i], " <-> ", $values2[$i], " <-> ", $values3[$i], "\n";
        }

    }

}


do {
    print "Show arrays (yes/no)?"; chomp($show = <STDIN>);
} while (!( $show == "yes" || $show == "no" ));


if ( $show == "yes" ) {

    for ($i = 0; $i <= $elementCount - 1; $i += (1)) {
        print "[", $i, "]:\t", $values1[$i], "\t", $values2[$i], "\t", $values3[$i], "\n";
    }

}
