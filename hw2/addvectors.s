; Author: Jorge Pena
; Email: blaenkdenum@csu.fullerton.edu
; Course: CPSC240
; Purpose: a subprogram that adds two vectors, component-wise, storing each result into a third array

extern printf

segment .data

segment .bss

segment .text
  global addvectors

addvectors:
  mov qword r11, 0  ; the counter for iteration
  mov r12, rdi  ; the first array
  mov r13, rsi  ; the second array
  mov r14, rdx  ; the result array that will hold the component-wise sum
  mov r15, rcx  ; the length
  
loopints:
  cmp qword r11, r15  ; see if we're past the last element of the array
  je endloop          ; if so, jump out of the loop

  mov qword rax, [r12+8*r11]  ; set the initial value to be the first array's component
  add qword rax, [r13+8*r11]  ; add to the temporary value the second array's component
  mov qword [r14+8*r11], rax  ; put the sum in the correct position in the result array

  inc r11       ; increment the loop counter
  jmp loopints  ; repeat the loop

endloop:
  xor rax, rax ; return nothing since the result is in the third passed array
  ret


