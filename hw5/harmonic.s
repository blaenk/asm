; Author: Jorge Peña
; Email: blaenkdenum@csu.fullerton.edu
; Course: CPSC240
; Assignment: #5 Harmonic Series
; Due: 2012-Apr-3
; File: harmonic.s
; Purpose: implement the harmonic series in x86-64 with the x87FPU

%include "debug.inc"

extern printf
extern __isoc99_scanf       ; this scanf allows 80-bit floating input

segment .data
  ; the prompt strings
  prompt db "Please enter a real number for x: ",  0

  ; clock messages
  currentclockmsg db "The current time on the clock is %ld", 10, 0
  resultclockmsg db "The result has been computed and the clock shows %ld", 10, 0

  ; result messages
  resultmsg db "The smallest number of terms with harmonic sum greater than x is %ld, and that sum is %-#20.20Lf", 10, 0

  ; 2.4 GHz /IS/ the speed of my processor
  totalcyclesmsg db "The computation required %ld clock cycles, which is %-#20.20Lf ns on my 2.4 GHz machine.", 10, 0

  ; the conclusion
  goodbye db 10, "Have a harmonic day.", 10, 0

  ; scanf formats
  doubleinputformat db "%Lf", 0

  clockrate dq 2.4                        ; this is my processor's clockrate
  termcounter dq 0                        ; this counts the current term in the harmonic series

segment .bss
  ; these will only be used to store the values input by scanf, then they'll be placed on the FPU87 stack

  currentclock resq 1    ; current time
  resultclock resq 1     ; result clock time
  totalcycles resq 1     ; total clock cycles elapsed

segment .text
  global harmonic

harmonic:
  push rbp          ; save the stack frame of the caller
  mov rbp, rsp      ; initiate a new stack frame

  finit             ; clean out the FPU stack

  ; ask for 'x'
  xor rbx, rbx
  mov qword rax, 0
  mov rdi, prompt          ; ask for x
  call printf

  ; scan x
  mov qword rax, 0
  mov rdi, doubleinputformat  ; tell scanf what data format to expect
  push qword 0                ; reserve space for the 80-bit float
  push qword 0
  mov rsi, rsp                ; store the input into rsp (top of stack)
  call __isoc99_scanf

  fld1                        ; push a 1.0 on the stack, it'll be divided by the harmonic term on each iteration
  fld tword [rsp]             ; load and push the new input number onto st1 (x)

  pop rax
  pop rax                     ; undo the space we reserved for the input

  fldz                        ; load 0.0 to the top of the stack to serve as our initial total

  xor rax, rax                ; make sure neither of these registers interfere with the subsequent calls
  xor rdx, rdx

  cpuid                       ; allow all of the instructions to finish before we take the time
  rdtsc                       ; store the timestamp into RDX:RAX

  ; RDX:RAX
  ;   RDX: has higher order 32 bits
  ;   RAX: has lower order 32 bits

  ; Both have the 32-bits in the lower end (EDX:EAX), so we need to shift RDX left by 32 bits, then OR it with RAX

  showregisters 3             ; output the registers so we can see what's in rdx

  shl rdx, 32                 ; shift the lower order 32-bits of rdx to the higher end
  or rax, rdx                 ; merge the higher-order bits of rdx with lower-order bits of rax

  ; rax now contains the complete number
  mov [currentclock], rax     ; store the cycle count in currentclock

  mov qword rax, 0            ; clear out the registers used by rdtsc
  mov qword rdx, 0

  mov rdi, currentclockmsg    ; output the clock count before the math
  mov rsi, [currentclock]
  call printf

partial_sum:                  ; this label is in charge of applying another harmonic term
  inc qword [termcounter]     ; increment the term counter

  ; apply a partial sum
  fild qword [termcounter]    ; load the number of the partial sum we are applying
  fdivr st0, st3              ; divide 1 by the term count (1 / N) and store it at st0
  faddp st1                   ; add the result (st0) to the total we have accrued so far (st1) and pop the stack

  fcom st1                    ; compare this new total in st0 with the user-input threshold in st1
  fstsw ax                    ; retrieve the status word of the comparison
  sahf                        ; set low byte of flags word according to contents of ah

  ja done                     ; if the sum is larger than the treshold x, then we're done
  jmp partial_sum             ; otherwise apply another partial sum

done:
  xor rax, rax                ; make sure rax does not interfere with subsequent calls
  cpuid                       ; allow all of the previous instructions to finish before we take the time
  rdtsc                       ; store the timestamp in RDX:RAX

  ; RDX:RAX
  ;   RDX: has higher order 32 bits
  ;   RAX: has lower order 32 bits

  ; Both have the 32-bits in the lower end (EDX:EAX), so we need to shift RDX left by 32 bits, then OR it with RAX
  shl rdx, 32                 ; shift the lower order 32-bits of rdx to the higher end
  or rax, rdx                 ; merge the bits of rax and rdx into rax

  ; rax now contains the complete number
  mov [resultclock], rax      ; store the cycle count in resultclock

  mov qword rax, 0
  mov rdi, resultclockmsg     ; output the clock cycle count after the answer was found
  mov rsi, [resultclock]
  call printf

  push qword 0                ; reserve space on the stack for the 80-bit number
  push qword 0

  fstp tword [rsp]            ; pop st0 from the FPU stack and store it in the integer stack

  mov qword rax, 1            ; tell printf we're printing one float
  mov rdi, resultmsg          ; output the result message
  mov rsi, [termcounter]      ; also output the term count
  call printf

  pop rax                     ; undo reserve space for 80-bit number
  pop rax

  ; compute the total cycles
  mov r10, [resultclock]      ; put the end cycle count in r10
  sub r10, [currentclock]     ; subtract the start cycle count from r10
  mov [totalcycles], r10      ; put the result in totalcycles

  finit                       ; clear out the FPU

  ; compute the nanoseconds elapsed
  fld qword [clockrate]       ; push the processor clockrate onto the stack
  fild qword [totalcycles]    ; push the total cycles elapsed onto the stack
  fdiv st1                    ; divide the total cycles by the clockrate

  push qword 0                ; reserve space on the stack for the 80-bit number
  push qword 0

  fstp tword [rsp]            ; retrieve the 80-bit number fro the FPU stack onto the integer stack

  mov qword rax, 1            ; tell printf we're printing a float
  mov rdi, totalcyclesmsg     ; output the total cycles elapsed message
  mov rsi, [totalcycles]      ; total cycles elapsed
  call printf

  pop rax                     ; undo the space reservation
  pop rax

  mov qword rax, 0
  mov rdi, goodbye            ; output the harmonic goodbye
  call printf

  mov rsp, rbp                ; restore the caller's frame pointer
  pop rbp

  ; exit
  xor rax, rax ; if we got here then assume success, zero out rax to indicate this
  ret

