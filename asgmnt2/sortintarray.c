// Author: Jorge Pena
// Email: blaenkdenum@csu.fullerton.edu
// File: sortintarray.c
// Course: CPSC240
// Purpose: this subprogram takes in an array and its length and sorts it using bubblesort

#include <stdio.h>

// credit to: http://www.algorithmist.com/index.php/Bubble_sort.c

long int sortarray(long int *array, long int length);

long int sortarray(long int *array, long int length) {
  int temp = 0; // temporary value for swapping

  for (int i = length - 1; i > 0; i--) { // the sorted region
    for (int j = 1; j <= i; j++) { // the unsorted region
      if (array[j - 1] > array[j]) { // is this element in the wrong position
        // if so swap it with the correct one
        temp = array[j - 1];
        array[j - 1] = array[j];
        array[j] = temp;
      }
    }
  }

  return 0;
}
