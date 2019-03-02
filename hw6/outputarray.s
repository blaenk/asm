; Author: Jorge Peña
; Email: blaenkdenum@csu.fullerton.edu
; Course: CPSC240
; Assignment: #6 Statistical Analysis
; Due: 2012-May-10
; File: outputarray.s
; Purpose: output an array

extern printf

segment .data
  resultmsg db "%-#15.15lf", 10, 0

segment .bss
  array resq 1                    ; to hold the address of the array
  size resq 1                     ; to hold the size of the array

segment .text
  global outputarray

outputarray:
  push rbp                        ; save the stack frame of the caller
  mov rbp, rsp                    ; initiate a new stack frame

  mov [array], rdi                ; save the passed in address of the array
  mov [size], rsi                 ; save the passed in size of the array

  xor r15, r15                    ; zero out the regsiter we'll use for counting

loop:
  mov r12, [array]                ; reload the address of the array
  mov r13, [size]                 ; reload the size of the array

  mov qword rax, 1                ; tell printf we're printing a float
  movsd xmm0, [r12+8*r15]         ; put the next element into xmm0 for printf
  mov rdi, resultmsg              ; give printf the format we want to print the value as
  call printf                     ; call printf

  inc r15                         ; increment the loop counter
  cmp r15, r13                    ; check if we've reached the limits fo the array
  jl loop                         ; if not, then loop one more time

  mov rsp, rbp                    ; restore the caller's frame pointer
  pop rbp

  xor rax, rax                    ; returns nothing so return 0
  ret


