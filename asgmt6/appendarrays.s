; Author: Jorge Peña
; Email: blaenkdenum@csu.fullerton.edu
; Course: CPSC240
; Assignment: #6 Statistical Analysis
; Due: 2012-May-10
; File: appendarrays.s
; Purpose: concatenate two arrays, gets passed both arrays and their sizes

extern printf
extern malloc

segment .data

segment .bss
  firstarray resq 1                             ; to hold the address of the first array
  firstarraysize resq 1                         ; to hold the size of the first array

  secondarray resq 1                            ; same for the second array
  secondarraysize resq 1

  concatenatedarraysize resq 1                  ; to hold the size of the concatenated array

segment .text
  global appendarrays

appendarrays:
  push rbp                                      ; save the stack frame of the caller
  mov rbp, rsp                                  ; initiate a new stack frame

  mov [firstarray], rdi                         ; save the passed in address of the first array
  mov [firstarraysize], rsi                     ; save the size of the first array

  mov [secondarray], rdx                        ; save the passed in address of the second array
  mov [secondarraysize], rcx                    ; save the size of the first array

  mov rdi, [firstarraysize]                     ; determine the size of the concanted array
  add rdi, [secondarraysize]                    ; which is the sum of the sizes of both arrays

  imul rdi, 8                                   ; now turn it into bytes, each element is 8 bytes (double), so size * 8
  mov [concatenatedarraysize], rdi              ; save the computed size for later

  call malloc                                   ; call malloc with the desired size in rdi, rax will contain the address of the allocated array

  mov qword r14, 0                              ; zero the loop counter

                                                ; loop and copy the elements from the first array into the concatenated array
firstarraycopy:
  mov r12, [firstarray]                         ; reload the address of the first array
  mov r13, [firstarraysize]                     ; reload the address of the second array

  mov r15, [r12+8*r14]                          ; extract the current element from the first array
  mov [rax+8*r14], r15                          ; store it in the new array at the appropriate position

  inc r14                                       ; increment the loop counter
  cmp r14, r13                                  ; determine if we've reached the limits of the array
  jl firstarraycopy                             ; if not, loop one more time

  mov qword r14, 0                              ; reset the loop counter

                                                ; loop and copy the elements of the second array into the concatenated array
secondarraycopy:
  mov r12, [secondarray]                        ; reload the address of the second array
  mov r13, [secondarraysize]                    ; reload the size of the second array

  mov r15, [r12+8*r14]                          ; extract the current element from the second array
  mov r11, r14                                  ; determine the destination position of the concatenated array
  add r11, [firstarraysize]                     ; determined by offsetting (adding) the current counter and the size of the first array
  mov [rax+8*r11], r15                          ; move the second array element into the concatenated array

  inc r14                                       ; increment the loop counter
  cmp r14, r13                                  ; determine if we've reached the limits of the array
  jl secondarraycopy                            ; if not, loop one more time

  mov rsp, rbp                                  ; restore the caller's frame pointer
  pop rbp

  ret                                           ; don't zero rax because it contains the address of the concatenated array


