; Author: Jorge Peña
; Email: blaenkdenum@csu.fullerton.edu
; Course: CPSC240
; Assignment: #6 Statistical Analysis
; Due: 2012-May-10
; File: getmin.s
; Purpose: determine the smallest value in an array

extern printf

segment .data

segment .bss
  array resq 1                  ; to hold the address of the array
  size resq 1                   ; to hold the size of the array

segment .text
  global getmin

getmin:
  push rbp                      ; save the stack frame of the caller
  mov rbp, rsp                  ; initiate a new stack frame

  mov [array], rdi              ; save the address of the array that was passed
  mov [size], rsi               ; save the size of the array that was passed

  movsd xmm0, [r12]             ; assume the first element is the min for now, store in xmm0

  mov qword r15, 1              ; so make the loop counter skip the first element

loop:
  mov r12, [array]              ; reload the address of the array
  mov r13, [size]               ; reload the size of the arary

  movsd xmm1, [r12+8*r15]       ; load the next element of the array into xmm1
  minpd xmm0, xmm1              ; keep the minimum of xmm0 and xmm1 in xmm0

  inc r15                       ; increment the loop counter
  cmp r15, r13                  ; determine if we've reached the limits of the array
  jl loop                       ; if not, loop one more time

  mov rsp, rbp                  ; restore the caller's frame pointer
  pop rbp

  xor rax, rax                  ; the return value is already in xmm0, zero out rax
  ret

