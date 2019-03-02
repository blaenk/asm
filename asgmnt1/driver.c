//  Author: Jorge Peña
//  Email: blaenkdenum@csu.fullerton.edu
//  Course: CPSC240
//  Assignment: #1 Arithmetic
//  Due: 2012-Feb-7
//  File: driver.c

#include <stdio.h>
#include <stdint.h>

extern unsigned long int arithmetic();

int main(int argc, char **argv) {
   unsigned long int return_code = 1;

   printf("Welcome to Jorge's arithmetic assignment\n");

   return_code = arithmetic();

   printf("The result code is %lu\n", return_code);
   
   return return_code;
}
