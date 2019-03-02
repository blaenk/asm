//  Author: Jorge Peña
//  Email: blaenkdenum@csu.fullerton.edu
//  Course: CPSC240
//  Assignment: #4: area calculation
//  Due: 2012-Apr-1
//  File: driver.c

#include <stdio.h>
#include <stdint.h>

extern unsigned long int area();

int main(int argc, char **argv) {
   unsigned long int return_code = 1;

   printf("Welcome to CPSC 240 Assignment 4\n");

   return_code = area();

   printf("The return code is %lu\n", return_code);
   
   return return_code;
}
