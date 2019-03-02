// Author: Jorge Peña
// Email: blaenkdenum@csu.fullerton.edu
// Course: CPSC240
// Assignment: #6 Statistical Analysis
// Due: 2012-May-10
// File: readarray.cpp
// Purpose: reads in an array

#include <iostream>
#include <algorithm>
#include <string>
#include <vector>
using namespace std;

extern "C" double *readarray(long int *size);

// passed a variable that will hold the size of the allocated array
// returns the address of the newly allocated array
double *readarray(long int *size) {
  string response = "Y";                                 // holds the user's response
  vector<double> floats;                                 // dynamic array to hold user-input values
  double enteredFloat = 0.0;                             // holds the user-input floating point value

  // keep taking input until the user chooses to stop by pressing n
  while (response[0] != 'n') {
    // ask for the value
    cout << "Enter float number: ";
    cin >> enteredFloat;

    // add it to the vector
    floats.push_back(enteredFloat);

    // ask if they wish to enter more
    cout << "Are there more inputs?: ";
    cin >> response;

    // turn the response to lower case for easier comparison
    transform(response.begin(), response.end(), response.begin(), ::tolower);
  }

  // create a regular c-array of the same size as the vector
  double *newarray = new double[floats.size()];

  // copy the vector elements into the new array
  copy(floats.begin(), floats.begin() + floats.size(), newarray);

  // set the passed in variable to the size of the array
  *size = floats.size();

  // return the address of the array
  return newarray;
}
