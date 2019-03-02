; Author: Jorge Pena
; Email: blaenkdenum@csu.fullerton.edu
; Course: CPSC240
; Purpose: this subprogram calculates the dot product of two arrays using
;   two subprograms, one to calculate the component-wise
;   products of two arrays and another subprogram to calculate the sum of each product
;   in that resulting array

extern printf
extern multiplyvectors
extern sumarray

segment .data

segment .bss
  products resq 20  ; this array will hold the product vector resulting from the call to multiplyvectors

segment .text
  global dotprod

dotprod:
  mov qword r12, 0  ; the counter for iteration
  mov r13, rdi  ; the first array
  mov r14, rsi  ; the second array
  mov r15, rdx  ; the length

  ; save these registers of importance so that multiplyvectors doesn't overwrite them
  push r12
  push r13
  push r14
  push r15
  
  ; determine the component-wise products of both arrays
  mov qword rax, 0    ; the necessary arguments are already in rdi, rsi, and rdx
  mov rcx, products   ; just need result array to store the products in
  call multiplyvectors

  ; recover the registers we established initially
  pop r15
  pop r14
  pop r13
  pop r12

  ; now pass the products array to the sumarray function
  mov qword rax, 0
  mov rdi, products ; give it the array of products which it will sum together
  mov rsi, r15      ; give it the length of the array so that it can safely iterate through it
  call sumarray

  ret ; the sum is already in rax since sumarray put it there, so just return



