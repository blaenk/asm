; Author: Jorge Pena
; Email: blaenkdenum@csu.fullerton.edu
; File: writeintarray.s
; Course: CPSC240
; Purpose: this subprogram takes an array and its length and prints out each element

extern printf

segment .data
  ; printf formats
  longintformat db "%li ", 0    ; the format to print out a signed long integer
  newline db 10                 ; an ascii newline to finish off printing the array

segment .bss

segment .text
  global writeints

writeints:
  mov r13, rdi  ; the array to print
  mov r14, rsi  ; the length
  mov qword r15, 0  ; the counter for iteration

loopints:
  cmp qword r15, r14  ; see if we're past the last element of the array
  je endloop  ; if so then exit the loop

  ; print out the current element based on the counter
  mov qword rax, 0
  mov rdi, longintformat
  mov qword rsi, [r13+8*r15]    ; print out element at the current index based on the current loop counter
  call printf

  inc r15               ; increment the loop counter
  jmp loopints          ; repeat the loop

endloop:
  ; the array is done printing, finish off with a newline
  mov qword rax, 0
  mov rdi, newline  ; the newline in ascii
  call printf

  ; exit, nothing to return
  xor rax, rax
  ret

