// Author: Jorge Peña
// Email: blaenkdenum@csu.fullerton.edu
// Course: CPSC240
// Assignment: #6 Statistical Analysis
// Due: 2012-May-10
// File: getvariance.cpp
// Purpose: calculate the variance of an array

#include <iostream>
using namespace std;

extern "C" double getvariance(double *array, int size, double mean);

// passed the address of the array, the size, and the mean
// returns the variance fo the array
double getvariance(double *array, int size, double mean) {
  double variance = 0.0;    // to hold the variance

  // loop through the array summing up the square distances of each element from the mean
  for (int i = 0; i < size; i++) {
    variance += (array[i] - mean) * (array[i] - mean);
  }

  // divide the variance by the size of the array - 1
  variance /= (size - 1);

  // return the varaince
  return variance;
}
