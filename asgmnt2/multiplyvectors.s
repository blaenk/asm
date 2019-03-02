; Author: Jorge Pena
; Email: blaenkdenum@csu.fullerton.edu
; File: multiplyvectors.s
; Course: CPSC240
; Purpose: this subprogram multiplies two vectors component-wise and stores each result in a third array

extern printf

segment .data

segment .bss

segment .text
  global multiplyvectors

multiplyvectors:
  mov qword r11, 0  ; the counter for iteration
  mov r12, rdi  ; the first array
  mov r13, rsi  ; the second array
  mov r14, rdx  ; the length
  mov r15, rcx  ; the result array
  
loopints:
  cmp qword r11, r14  ; see if we're past the last element of the array
  je endloop          ; if so, jump out of the loop, we're done

  mov qword rax, [r12+8*r11]  ; set the initial value to be the first array's component
  imul qword [r13+8*r11]      ; multiply to the temporary value the second array's component
  mov qword [r15+8*r11], rax  ; then store the product into the result array
  xor rax, rax                ; reset rax just to be safe

  inc r11           ; increment the loop counter
  jmp loopints      ; repeat the loop

endloop:
  ; exit. no return value since the work is done on the result array
  xor rax, rax
  ret




