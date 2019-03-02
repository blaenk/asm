// Author: Jorge Peña
// Email: blaenkdenum@csu.fullerton.edu
// Course: CPSC240
// Assignment: #6 Statistical Analysis
// Due: 2012-May-10
// File: getmax.c
// Purpose: determine the largest element in an array

// macro of the max
#define max(a,b) ((a)<(b) ? (b) : (a))

extern double getmax(double *array, int size);

// passed the address of the array and the size
// returns the largest element in the array
double getmax(double *array, int size) {
  double largest = array[0];          // assume the largest value is the first one for now

  // loop through the array finding larger numbers
  for (int i = 1; i < size; i++) {
    largest = max(largest, array[i]);
  }

  // return the largest number
  return largest;
}
