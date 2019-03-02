// Author: Jorge Peña
// Email: blaenkdenum@csu.fullerton.edu
// Course: CPSC240
// Assignment: #6 Statistical Analysis
// Due: 2012-May-10
// File: getmean.cpp
// Purpose: calculate the mean of an array

extern "C" double getmean(double *array, int size);

// passed the address of the array and the size of the array
// returns the mean of the array
double getmean(double *array, int size) {
  double mean = 0.0;        // to hold the mean

  // add up the elements of the array
  for (int i = 0; i < size; i++) {
    mean += array[i];
  }

  // then divide the sum by the size
  mean /= size;

  // return the mean
  return mean;
}
