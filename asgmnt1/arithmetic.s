; Author: Jorge Peña
; Email: blaenkdenum@csu.fullerton.edu
; Course: CPSC240
; Assignment: #1 Arithmetic
; Due: 2012-Feb-7
; File: arithmetic.s

extern printf
extern scanf

segment .data
  ; the prompt strings
  firstprompt db "Enter the first signed integer: ",  0
  secondprompt db "Enter the second signed integer: ", 0

  ; the response strings
  entered db "You entered %li (signed) decimal = %#016lx (unsigned) hex", 10, 0

  ; the product overflow message requires two subsequent 64-bit hex numbers
  overflowmsg db "The product requires more than 64 bits. Its value is %#016lx%016lx (unsigned) hex", 10, 0

  ; this result message is generalized and can be used for product, quotient, and remainder messages
  resultmsg db "The %s is %li (signed) decimal = %#016lx (unsigned) hex", 10, 0

  ; the result message specifiers
  productstr db "product", 0
  quotientstr db "quotient", 0
  remainderstr db "remainder", 0

  ; the conclusion
  goodbye db "I hope you enjoyed using my program as much as I enjoyed making it. Bye", 10, 0

  ; scanf formats
  unsignedlongintegerformat db "%lu", 0

segment .bss
  firstint resq 1 ; to store the first integer input by the user
  secondint resq 1 ; to store the second integer input by the user

  productHi resq 1 ; to store the high quadword in case of overflow
  productLo resq 1 ; to store the low quadword

  quotient resq 1 ; to store the quotient of the division
  remainder resq 1 ; to store the remainder of the division

segment .text
  global arithmetic

arithmetic:
  ; ask for the first integer
  xor rbx, rbx
  mov qword rax, 0
  mov rdi, firstprompt
  call printf

  ; scan the first integer
  mov qword rax, 0
  mov rdi, unsignedlongintegerformat ; tell scanf what data format to expect
  mov rsi, firstint
  call scanf

  ; confirm
  mov qword rax, 0
  mov rdi, entered
  mov rsi, [firstint] ; pass it once for decimal representation
  mov rdx, [firstint] ; and again for hex representation
  call printf

  ; ask for the second integer
  xor rbx, rbx
  mov qword rax, 0
  mov rdi, secondprompt
  call printf

  ; scan the second integer
  mov qword rax, 0
  mov rdi, unsignedlongintegerformat ; tell scanf what data format to expect
  mov rsi, secondint
  call scanf

  ; confirm
  mov qword rax, 0
  mov rdi, entered
  mov rsi, [secondint] ; decimal representation
  mov rdx, [secondint] ; hex representation
  call printf

  ; multiply them
  mov rax, [firstint]
  imul qword [secondint] ; multiply secondint with firstint, result stored in rdx:rax
  mov [productHi], rdx ; get the top 64-bit number from rdx
  mov [productLo], rax ; get the bottom 64-bit number from rax

  jo overflowed ; if there was an overflow, jump to the handler labeled 'overflow'

  ; output the result
  mov qword rax, 0
  mov rdi, resultmsg
  mov rsi, productstr
  mov rdx, [productLo] ; only output the low quadword because there was no overflow
  mov rcx, [productLo] ; this time do it in hex
  call printf

  jmp division ; unconditionally jump to the division section

overflowed:
  ; output the hex representation of the 128-bit result
  mov qword rax, 0
  mov rdi, overflowmsg ; the string to output is the overflow message
  mov rsi, [productHi] ; first the high quadword
  mov rdx, [productLo] ; then the low
  call printf

division:
  ; do the division
  ; imul treats the dividend as a 128-bit integer composed of rdx:rax
  ; since we want the dividend to be 64-bits, we'll only set rax and zero out rdx
  ; this makes rdx:rax == rax
  mov qword rax, [firstint]
  mov qword rdx, 0
  idiv qword [secondint]
  mov [quotient], rax ; get the quotient from rax
  mov [remainder], rdx ; get the remainder from rdx

  ; output the quotient
  mov qword rax, 0
  mov rdi, resultmsg
  mov rsi, quotientstr
  mov rdx, [quotient] ; in decimal form
  mov rcx, [quotient] ; and in hex form
  call printf

  ; output the remainder
  mov qword rax, 0
  mov rdi, resultmsg
  mov rsi, remainderstr
  mov rdx, [remainder] ; in decimal
  mov rcx, [remainder] ; and hex
  call printf

  ; say goodbye
  mov qword rax, 0
  mov rdi, goodbye
  call printf

  ; exit
  xor rax, rax ; if we got here then assume success, zero out rax to indicate this
  ret
