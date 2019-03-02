// Author: Jorge Peña
// Email: blaenkdenum@csu.fullerton.edu
// Course: CPSC240
// Assignment: #6 Statistical Analysis
// Due: 2012-May-10
// File: sumarray.c
// Purpose: calculate the sum of the array

extern double getsum(double *array, int size);

// passed the array and the size
// returns the sum of the elements
double getsum(double *array, int size) {
  double sum = 0.0;         // holds the sum of the array

  // sum up the elements
  for (int i = 0; i < size; i++) {
    sum += array[i];
  }

  // return the sum
  return sum;
}

