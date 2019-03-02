; Author: Jorge Pena
; Email: blaenkdenum@csu.fullerton.edu
; Course: CPSC240
; File: readintarray.s
; Purpose: this subprogram reads in a variable amount of integers and stores them in an array

extern printf
extern scanf
extern getchar

segment .data
  ; these are the prompts for data
  loopprompt db "Do you have more data (Y or N)?: ", 0  ; asks if there is more data
  valueprompt db "Enter next value: ", 0                ; asks for the next value

  ; scanf formats
  charformat db "%c", 0
  longintformat db "%li", 0

segment .bss
  response resq 1   ; the character input (Y or N)
  integer resq 1    ; the current value input (integer)

segment .text
  global readints

readints:
  mov r13, rdi        ; the array we are storing the values into
  mov qword r14, 0    ; the counter for iteration

loopints:
  ; read in the first integer
  mov qword rax, 0
  mov qword r15, 0
  mov rdi, longintformat
  mov rsi, integer        ; store the integer into the integer variable
  call scanf

  mov r15, [integer]  ; move the read integer into r15

  mov qword [r13+8*r14], r15  ; put the read-in integer into the correct position in the array

  ; get rid of extra newlines
  mov qword rax, 0
  call getchar        ; get rid of the newline

  inc r14 ; increment the loop counter

  ; ask if there is more data
  xor rbx, rbx
  mov qword rax, 0
  mov rdi, loopprompt ; asks if there is more data
  call printf

  ; get the character response (Y or N)
  mov qword rax, 0
  mov rdi, charformat
  push qword 0        ; reserve 8 bytes of binary zeroes on the stack
  mov rsi, rsp        ; make rsi point to the top of the stack
  mov qword rax, 0
  call scanf          ; the ascii value is now at the top of the stack

  pop qword [response]  ; so pop the ascii value into the response variable

  ; check the character to see if it's a capital N in ascii
  cmp qword [response], 78  ; check if the character is N (ascii decimal value 78)
  je endloop          ; if it is 78 (N), then exit out of the loop

  ; if we're still here then the user wants to input more data. prompt them for it
  mov qword rax, 0
  mov rdi, valueprompt  ; ask for the next value
  call printf

  jmp loopints        ; repeat the loop

endloop:
  mov qword rax, 0
  call getchar        ; get rid of the newline

  mov rax, r14  ; return the size of the array, helps other programs out with iteration
  ret ; exit this subprogram

