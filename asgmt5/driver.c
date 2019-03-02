//  Author: Jorge Peña
//  Email: blaenkdenum@csu.fullerton.edu
//  Course: CPSC240
//  Assignment: #5 Harmonic Series
//  Due: 2012-Apr-3
//  File: driver.c
//  Purpose: to call the assembly subprogram which calculates harmonic series

#include <stdio.h>
#include <stdint.h>

extern unsigned long int harmonic();

int main(int argc, char **argv) {
   unsigned long int return_code = 1;

   printf("Welcome to the harmonic series programmed by Jorge Pena.\n");

   return_code = harmonic();

   printf("The return code is %lu\n", return_code);
   
   return return_code;
}
