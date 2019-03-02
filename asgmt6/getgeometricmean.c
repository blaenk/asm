// Author: Jorge Peña
// Email: blaenkdenum@csu.fullerton.edu
// Course: CPSC240
// Assignment: #6 Statistical Analysis
// Due: 2012-May-10
// File: getgeometricmean.c
// Purpose: calculate the geometric mean of an array

#include <math.h>

extern double getgeometricmean(double *array, int size);

// passed the address of the array and the size
// returns the geometric mean of the array
double getgeometricmean(double *array, int size) {
  double geometricmean = 1.0;

  // multiply each element of the array by the absolute value of the next element
  for (int i = 0; i < size; i++) {
    geometricmean *= fabs(array[i]);
  }

  // then raise it to the 1/(size of array) power
  geometricmean = pow(geometricmean, 1.0/size);

  // return the geometric mean
  return geometricmean;
}
