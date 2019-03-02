//  Author: Jorge Peña
//  Email: blaenkdenum@csu.fullerton.edu
//  Course: CPSC240
//  Assignment: #4 Real Numbers
//  Due: 2012-Apr-3
//  File: driver.c
//  Purpose: to call the assembly subprogram which calculates triangle areas

#include <stdio.h>
#include <stdint.h>

extern unsigned long int areacalculator();

int main(int argc, char **argv) {
   unsigned long int return_code = 1;

   printf("Welcome to CPSC 240 Assignment 4\n");

   return_code = areacalculator();

   printf("The return code is %lu\n", return_code);
   
   return return_code;
}
