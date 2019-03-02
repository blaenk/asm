// Author: Jorge Pena
// Email: blaenkdenum@csu.fullerton.edu
// Course: CPSC240
// File: driver.c
// Purpose: this is the main driver of the overall program. it initiates the program
//  by calling maindriver which is defined in main.s

#include <stdio.h>
#include <stdint.h>

extern long int maindriver();

int main(int argc, char **argv) {
  long return_code = -99;
  printf("CPSC240 Assignment 2 by Jorge Pena\n");

  return_code = maindriver();
  printf("The return code is %ld\n", return_code);

  return 0;
}
