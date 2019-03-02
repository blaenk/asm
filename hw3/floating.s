; Author: Jorge Peña
; Email: blaenkdenum@csu.fullerton.edu
; Course: CPSC240
; Assignment: #1 Arithmetic
; Due: 2012-Feb-7
; File: floating.s

extern printf
extern scanf

segment .data
  ; the prompt strings
  introduction db "This program performs arithmetic operations on floating point numbers.", 10, 0
  firstprompt db "Please enter a floating point number: ",  0
  secondprompt db "Please enter another floating point number: ", 0

  ; the response strings
  entered db "You entered %-#16.16lf", 10, 0

  ; this result message is generalized and can be used for product, quotient, and remainder messages
  resultmsg db "The %s is: %-#16.16lf", 10, 0

  ; the result message specifiers
  sumstr db "sum", 0
  differencestr db "difference", 0
  productstr db "product", 0
  quotientstr db "quotient", 0

  ; the conclusion
  goodbye db "This accurate arithmetic was brought to you by Jorge Pena. Bye", 10, 0

  ; scanf formats
  doubleinputformat db "%lf", 0

segment .bss
  ; these are labeled floats, but they're actually 64-bit doubles

  firstfloat resq 1 ; to store the first integer input by the user
  secondfloat resq 1 ; to store the second integer input by the user
  resultfloat resq 1 ; to store the resulting float in each operation

segment .text
  global floating

floating:
  ; introduction
  mov qword rax, 0
  mov rdi, introduction
  call printf

  ; ask for the first float
  xor rbx, rbx
  mov qword rax, 0
  mov rdi, firstprompt
  call printf

  ; scan the first float
  mov qword rax, 0
  mov rdi, doubleinputformat ; tell scanf what data format to expect
  mov rsi, firstfloat
  call scanf

  ; confirm
  mov qword rax, 1            ; tell printf that we're sending it one float argument
  mov rdi, entered
  movsd xmm0, [firstfloat]
  sub rsp, 8                  ; the movs instructions require 16-byte boundaries on the stack
                              ; but the call instruction adds an 8-byte return address to the stack
                              ; so use up another 8 bytes on the stack (same as push qword 0) then pop it once done
  call printf
  add rsp, 8                  ; done with alignment

  ; ask for the second float
  xor rbx, rbx
  mov qword rax, 0
  mov rdi, secondprompt
  call printf

  ; scan the second float
  mov qword rax, 0
  mov rdi, doubleinputformat ; tell scanf what data format to expect
  mov rsi, secondfloat
  call scanf

  ; confirm
  mov qword rax, 1            ; tell printf that we're sending it one float argument
  mov rdi, entered
  movsd xmm0, [secondfloat]
  sub rsp, 8                  ; the movs instructions require 16-byte boundaries on the stack
                              ; but the call instruction adds an 8-byte return address to the stack
                              ; so use up another 8 bytes on the stack (same as push qword 0) then pop it once done
  call printf
  add rsp, 8                  ; done with alignment

  ; add the two floats
  movsd xmm0, [firstfloat]    ; load the first float
  addsd xmm0, [secondfloat]   ; add the secondfloat to the firstfloat
  movsd [resultfloat], xmm0   ; store the result into resultfloat

  ; print the sum
  mov qword rax, 1
  mov rdi, resultmsg
  mov rsi, sumstr
  movsd xmm0, [resultfloat]
  sub rsp, 8                  ; make sure the data is 16-byte aligned
  call printf
  add rsp, 8

  ; subtract the two floats
  movsd xmm0, [firstfloat]
  subsd xmm0, [secondfloat]
  movsd [resultfloat], xmm0

  ; print the difference
  mov qword rax, 1
  mov rdi, resultmsg
  mov rsi, differencestr
  movsd xmm0, [resultfloat]
  sub rsp, 8                  ; make sure the data is 16-byte aligned
  call printf
  add rsp, 8

  ; multiply the two floats
  movsd xmm0, [firstfloat]
  mulsd xmm0, [secondfloat]
  movsd [resultfloat], xmm0

  ; print the product
  mov qword rax, 1
  mov rdi, resultmsg
  mov rsi, productstr
  movsd xmm0, [resultfloat]
  sub rsp, 8                  ; make sure the data is 16-byte aligned
  call printf
  add rsp, 8

  ; divide the two floats
  movsd xmm0, [firstfloat]
  divsd xmm0, [secondfloat]
  movsd [resultfloat], xmm0

  ; print the quotient
  mov qword rax, 1
  mov rdi, resultmsg
  mov rsi, quotientstr
  movsd xmm0, [resultfloat]
  sub rsp, 8                  ; make sure the data is 16-byte aligned
  call printf
  add rsp, 8

  ; say goodbye
  mov qword rax, 0
  mov rdi, goodbye
  call printf

  ; exit
  xor rax, rax ; if we got here then assume success, zero out rax to indicate this
  ret
