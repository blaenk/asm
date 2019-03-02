// Author: Jorge Pena
// Email: blaenkdenum@csu.fullerton.edu
// File: sumarray.c
// Course: CPSC240
// Purpose: this subprogram takes an array and returns the sum of all of its elements

#include <stdio.h>

long int sumarray(long int *array, long int length);

long int sumarray(long int *array, long int length) {
  int sum = 0; // to hold the total sum

  // iterate through each element in the array
  for (int i = 0; i < length; i++) {
    sum += array[i]; // and add its value to the total sum
  }

  // return the total sum
  return sum;
}

