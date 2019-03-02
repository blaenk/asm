; Author: Jorge Peña
; Email: blaenkdenum@csu.fullerton.edu
; Course: CPSC240
; Assignment: #6 Statistical Analysis
; Due: 2012-May-10
; File: getstandarddeviation.s
; Purpose: calculate the standard deviation of an array

extern printf

segment .data

segment .bss
  array resq 1                    ; to hold the address of the array
  size resq 1                     ; to hold the size of the array

segment .text
  global getstandarddeviation

getstandarddeviation:
  push rbp                        ; save the stack frame of the caller
  mov rbp, rsp                    ; initiate a new stack frame

                                  ; the variance was passed in as xmm0
  sqrtsd xmm0, xmm0               ; take the square root of xmm0 and store it in xmm0

  mov rsp, rbp                    ; restore the caller's frame pointer
  pop rbp

  ; exit
  xor rax, rax                    ; the standard deviation is already in xmm0, zero out rax
  ret

