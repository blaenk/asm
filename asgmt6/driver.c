//  Author: Jorge Peña
//  Email: blaenkdenum@csu.fullerton.edu
//  Course: CPSC240
//  Assignment: #6 Statistical Analysis
//  Due: 2012-Apr-3
//  File: driver.c
//  Purpose: to call the assembly subprogram which calculates harmonic series

#include <stdio.h>
#include <stdint.h>

extern unsigned long int statistics();

int main(int argc, char **argv) {
   unsigned long int return_code = 1;

   printf("Welcome to Jorge Pena's Statistical Analyzer.\n");

   return_code = statistics();

   printf("Have a nice day. The return code is %lu. Bye\n", return_code);
   
   return return_code;
}
