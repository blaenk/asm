; Author: Jorge Peña
; Email: blaenkdenum@csu.fullerton.edu
; Course: CPSC240
; Assignment: #4 Real Numbers
; Due: 2012-Apr-3
; File: floating.s
; Purpose: to demonstrate real-world applications of the FPU stack, specifically, to calculate triangle areas

extern printf
extern scanf
extern getchar

segment .data
  ; the prompt strings
  introduction db "This program will find the area of your triangle.", 10, 0
  genericprompt db "Please enter the length of the %s side and press enter: ",  0
  loopprompt db "Do you have more input data (Y or N) ", 0

  ; generic prompt message specifiers
  firststr db "first", 0
  secondstr db "second", 0
  thirdstr db "third", 0

  ; the response strings
  entered db "You entered %-#20.20lf", 10, 0

  ; result messages
  resultmsg db "The area of this triangle is %-#20.20lf", 10, 0
  errormsg db "The area cannot be computed. Check your data and try again.", 10, 0

  ; the conclusion
  goodbye db "I hope you enjoyed your triangles.", 10, "This program was brought to you by Jorge Pena. Bye", 10, 0

  ; scanf formats
  doubleinputformat db "%lf", 0
  charformat db "%c", 0

  ; the divisor with which to divide the semiperimeter
  divisor dq 2

segment .bss
  ; these will only be used to store the values input by scanf, then they'll be placed on the FPU87 stack

  firstfloat resq 1             ; to store the first side
  secondfloat resq 1            ; to store the second side
  thirdfloat resq 1             ; to store the third side
  resultfloat resq 1            ; to store the resulting float when outputting
  response resq 1               ; to store the character input during the loop-data prompt

segment .text
  global areacalculator

areacalculator:
  ; introduction
  mov qword rax, 0
  mov rdi, introduction           ; output the introductory message
  call printf

beginning:
  finit                           ; clean out the FPU stack in case this is a subsequent iteration of data-input
  mov qword [divisor], 2          ; reset all of the values, the divisor is supposed to be 2
  mov qword [firstfloat], 0       ; the rest should be set to 0
  mov qword [secondfloat], 0
  mov qword [thirdfloat], 0
  mov qword [resultfloat], 0

  ; ask for the first float
  xor rbx, rbx
  mov qword rax, 0
  mov rdi, genericprompt          ; ask for the first float
  mov rsi, firststr
  call printf

  ; scan the first float
  mov qword rax, 0
  mov rdi, doubleinputformat  ; tell scanf what data format to expect
  mov rsi, firstfloat         ; specify that we want the first float
  call scanf

  ; confirmation
  mov qword rax, 1            ; tell printf that we're sending it one float argument
  mov rdi, entered
  movsd xmm0, [firstfloat]    ; store it in the firstfloat variable
  sub rsp, 8                  ; the movs instructions require 16-byte boundaries on the stack
                              ; but the call instruction adds an 8-byte return address to the stack
                              ; so use up another 8 bytes on the stack (same as push qword 0) then pop it once done
  call printf
  add rsp, 8                  ; done with alignment

  ; ask for the second float
  xor rbx, rbx
  mov qword rax, 0
  mov rdi, genericprompt      ; ask for the second float
  mov rsi, secondstr          ; specify that we want the second float
  call printf

  ; scan the second float
  mov qword rax, 0
  mov rdi, doubleinputformat  ; tell scanf what data format to expect
  mov rsi, secondfloat        ; store it in the secondfloat variable
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

  ; ask for the third float
  xor rbx, rbx
  mov qword rax, 0
  mov rdi, genericprompt      ; ask for the third float
  mov rsi, thirdstr           ; specify we want the third float
  call printf

  ; scan the third float
  mov qword rax, 0
  mov rdi, doubleinputformat  ; tell scanf what data format to expect
  mov rsi, thirdfloat         ; store the input in the thirdfloat variable
  call scanf

  ; confirm
  mov qword rax, 1            ; tell printf that we're sending it one float argument
  mov rdi, entered
  movsd xmm0, [thirdfloat]
  sub rsp, 8                  ; the movs instructions require 16-byte boundaries on the stack
                              ; but the call instruction adds an 8-byte return address to the stack
                              ; so use up another 8 bytes on the stack (same as push qword 0) then pop it once done
  call printf
  add rsp, 8                  ; done with alignment

  ; calculate the semiperimeter
  fild qword [divisor]        ; st4 store the divisor (2) for the semiperimeter
  fld qword [firstfloat]      ; st3 put all of the numbers onto the stack so that the third one is at the top
  fld qword [secondfloat]     ; st2
  fld qword [thirdfloat]      ; st1

  push qword 0                ; leave a blank spot for the results
  fild qword [rsp]            ; st0
  pop r11                     ; pop wherever
  
  fadd st1                    ; add the second number
  fadd st2                    ; add the third number
  fadd st3                    ; add the first number
  fdiv st4                    ; divide the result by the divisor, 2

  ; now that we have the semiperimter in st0, calculate heron's formula

  ; push 3 copies of the semiperimeter (st0) onto the stack
  fld st0                     ; st2
  fld st0                     ; st1
  fld st0                     ; st0

  ; stack is now like this:
  ; st0 = semiperimeter copy
  ; st1 = semiperimeter copy
  ; st2 = semiperimeter copy
  ; st3 = semiperimeter copy
  ; st4 = third side
  ; st5 = second side
  ; st6 = first side

  ; calculate the subtractions
  ; each time, since the target float is not in st0, we switch it with st0 and then switch back
  ; when we are done doing the subtraction
  fxch st1
  fsub st6               ; s - a
  fxch st1

  fxch st2
  fsub st5               ; s - b
  fxch st2

  fxch st3
  fsub st4               ; s - c
  fxch st3

  ; do the multiplications: s * (s - a)(s - b)(s - c)
  ; s, the untouched semiperimter, is in st0
  ; the sides subtracted from the semiprimeters are in st1-st3
  fmul st1                    ; * (s - a)
  fmul st2                    ; * (s - b)
  fmul st3                    ; * (s - c)

  ; check if the number is negative by storing it in memory and then using the cmp operator
  ; then a js jump (jump if signed)
  fst qword [resultfloat]
  cmp qword [resultfloat], 0
  js negative

  ; do the final square root to st0
  fsqrt

  ; to output the result we have to store the result in memory
  fst qword [resultfloat]     ; we have to put the 80-bit float into a 64-bit float (xmm0) to output

  mov qword rax, 1            ; tell printf we're printing one float
  mov rdi, resultmsg          ; output the result message
  movsd xmm0, [resultfloat]   ; printf expects the float in xmm0
  sub rsp, 8                  ; this is the same alignment adjusting that has been described three times above
  call printf
  add rsp, 8                  ; re-align

prompt:
  ; ask if they want more triangles
  mov qword rax, 0
  mov rdi, loopprompt         ; ask if they want to input more dat
  call printf

  mov qword rax, 0            ; get rid of any newlines from previous input/output
  call getchar

  ; get the character response (Y or N)
  mov qword rax, 0 
  mov rdi, charformat
  push qword 0                 ; reserve 8 bytes of binary zeroes on the stack
  mov rsi, rsp                 ; make rsi point to the top of the stack
  mov qword rax, 0             ; the ascii value is now at the top of the stack
  call scanf

  mov qword rax, 0            ; get rid of any newlines from previous input/output
  call getchar

  pop qword [response]          ; so pop the ascii value into the response variable

  cmp qword [response], 89      ; Y is ascii code 89
  je beginning                  ; if the user input a Y, then go back to the beginning

  ; if we got here then they do not want to enter more data, so say goodbye
  mov qword rax, 0
  mov rdi, goodbye
  call printf

  ; exit
  xor rax, rax ; if we got here then assume success, zero out rax to indicate this
  ret

negative:                  ; this section simply notifies the user that the triangle input is invalid
  mov qword rax, 0
  mov rdi, errormsg        ; notify the user that the area for such a "triangle" cannot be calculated
  call printf

  jmp prompt               ; then go to the prompt and ask the user if they would like to enter more data
