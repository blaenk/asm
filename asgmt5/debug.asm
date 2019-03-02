;File name: debug.asm
;Language: X86-64
;Usage: CPSC240
;Author: F. Holliday
;Last update: 20120129
;
;Program: showregisterssubprogram
;Purpose: Show the current state of X86-64 registers.
;This program is called by the macro code inside the file debug.inc.
;A program should bring in the debug.inc into an application program via a statement such as
;%include "debug.inc"

;Assemble: nasm -f elf64 -l debug.lis -o debug.o debug.asm

;X86 flags
;Bit# Mnemonic Name
;  0     CF    Carry flag
;  1           unused
;  2     PF    Parity flag
;  3           unused
;  4     AF    Auxilliary Carry flag
;  5           unused
;  6     ZF    Zero flag
;  7     SF    Sign flag
;  8     TF    Trap flag
;  9     IF    Interrupt flag
; 10     DF    Direction flag
; 11     OF    Overflow flag

;Set constants via assembler directives
%define qwordsize 8                     ;8 bytes
%define cmask 00000001h                 ;Carry mask
%define pmask 00000004h                 ;Parity mask
%define amask 00000010h                 ;Auxiliary mask
%define zmask 00000040h                 ;Zero mask
%define smask 00000080h                 ;Sign mask
%define dmask 00000400h                 ;Not used
%define omask 00000800h                 ;Overflow mask

extern printf

segment .data                           ;This segment declares initialized data

;There is a question regarding which format specifier to use.  The following appear to hold:
; "%x" designates 32-bit hex output with leading zeros supressed.
; "%lx" designates 64-bit hex output
; "%llx" designates 128-bit hex output
; "%lllx" designates 256-bit hex output
; "%llld" designates 256-bit decimal output
; "%8x" designates 32-bit hex output in 8 columns
; "%016lx" designates 64-bit hex output in 16 columns with leading zeros displayed.

registerformat1 db "Register Dump # %ld", 10,
                db "rax = %016lx rbx = %016lx rcx = %016lx rdx = %016lx", 10,
                db "rsi = %016lx rdi = %016lx rbp = %016lx rsp = %016lx", 10, 0

registerformat2 db "r8  = %016lx r9  = %016lx r10 = %016lx r11 = %016lx", 10,
                db "r12 = %016lx r13 = %016lx r14 = %016lx r15 = %016lx", 10, 0

registerformat3 db "rip = %016lx", 10, "rflags = %016lx ",
                db "of = %1x sf = %1x zf = %1x af = %1x pf = %1x cf = %1x", 10, 0

segment .text

global showregisterssubprogram

;CCC-64 sequence of parameters (left to right):
;  1st  rdi
;  2nd  rsi
;  3nd  rdx
;  4rd  rcx
;  5th  r8
;  6th  r9
;  remainder on stack right to left

showregisterssubprogram:

;When using this subprogram many resgisters will be modified; however, rsp and rbp are intentionally not modified.
;Seg faults have been known to result after modifying either of those registers.

;Save rflags because it is volatile and subject to change.
pushf                                             ;This instruction pushes rflags.

;Save current values: 8 pushes
push qword rax
push qword rdi
push qword rsi
push qword rdx
push qword rcx
push qword r8
push qword r9
push qword r11                                    ;r11 is a special case.  It is known that printf sometimes modifies
;                                                 ;r11.  For that reason r11 is saved here.  printf should not modify
;                                                 ;anything; perhaps this is a bug in printf.

;First part of the CCC-64 protocol setup: 4 pushes in order right to left
push qword rsp
push qword rbp
push qword rdi
push qword rsi

;Second part of the CCC-64 protocol setup
mov qword r9, rdx
mov qword r8, rcx
mov qword rcx, rbx
mov qword rdx, rax
mov qword rsi, [rsp+14*qwordsize]                 ;14 = #pushes + 1 ;1qword = 8bytes = 64bits ;1byte = 8bits
mov qword rdi, registerformat1

;Third part of the CCC-64 protocol setup
mov qword rax, 0                                  ;No variant parameters
call printf

;Reverse the previous pushes: perform 11 pops in reverse order, but do not pop rflags
pop rsi
pop rdi
pop rbp                                           ;Be careful about modifying rbp and rsp
pop rax                                           ;Do not update the rsp, but rather pop the stack and discard the value
pop r11
pop r9
pop r8
pop rcx
pop rdx
pop rsi
pop rdi
pop rax
;Now rflags is on top of the stack.

;Now begin process of outputting lines 4 and 5 of the register dump

;Save values that might be lost in this process
push qword rdi
push qword rsi
push qword rdx
push qword rcx
push qword r8
push qword r9
push qword rax
push qword r11

;First part of CCC-64 protocol setup: 3 pushes of parameters from right to left
push qword r15
push qword r14
push qword r13

;Second part of CCC-64 protocol setup: assign parameters in this case from left to right
mov qword rdi, registerformat2
mov qword rsi, r8
mov qword rdx, r9
mov qword rcx, r10
mov qword r8, r11
mov qword r9, r12

;Third part of CCC-64
mov qword rax, 0
call printf                                       ;r11 may be modified.

;Reverse the previous pushes: perform 10 pops in reverse order
pop r13
pop r14
pop r15
pop r11
pop rax
pop r9
pop r8
pop rcx
pop rdx
pop rsi
pop rdi

;Now begin process of outputting lines 6 and 7.

;At this time the original value of rflags is on top of the stack.

;Save values that might be lost in the process that follows: 8 pushes
push qword rdi
push qword rsi
push qword rdx
push qword rcx
push qword r8
push qword r9
push qword rax
push qword rbx
push qword r11

;Go into the stack and get a copy of that original rflags
mov qword rbx, [rsp+9*qwordsize]                  ;9 pushes each storing 8 bytes

;First part of CCC-64 protocol setup: do the pushes for the right most parameters
;Begin process to extract the cf bit, which is bit #0 from the right.
mov rax, rbx                                      ;Place a copy of rflags into rax
and rax, cmask                                    ;rax has all zero bits except possibly position 0.
push qword rax

;Begin process to extract the pf bit
mov rax, rbx                                      ;Place a new copy of rflags into rax
and rax, pmask                                    ;rax has all zero bits except possible position 2
shr rax, 2                                        ;The pf bit is bit #2 from the right.
push qword rax

;Begin process to extract the af bit
mov rax, rbx
and rax, amask
shr rax, 4                                        ;The af bit is bit #4 from the right.
push qword rax

;Second part of CCC-64 protocol setup: move data into the five fixed registers acting as parameters

;Begin process to extract the zf bit
mov rax, rbx
and rax, zmask
shr rax, 6
mov qword r9, rax

;Begin process to extract the sf bit
mov rax, rbx
and rax, smask
shr rax, 7
mov qword r8, rax

;Begin process to extract the of bit
mov rax, rbx
and rax, omask
shr rax, 11
mov qword rcx, rax

mov qword rdx, rbx                                ;Copy the original flags data to rdx
;
;rip is a highly protected register in the sense that it is the only one providing neither read nor write priveledges.
;Therefore, the programmer cannot assign a value to rip nor read the value in rip.  The one technique to obtain the
;value store in rip is to call a subprogram such as this one, showregisterssubprogram.  The call will place a copy 
;of rip on the integer stack.  That value can be retrieved later from the integer stack, and that is what is done 
;here.  That value is the address of the next instruction to execute when the current subprogram returns.
mov qword rsi, [rsp+13*qwordsize]                 ;13*8 = 104.  There were 13 pushes.
mov qword rdi, registerformat3

;Third part of the CCC-64 protocol
mov qword rax, 0
call printf

;Reverse the previous pushes: perform 12 pops in reverse order
pop rax                                           ;Discard the popped value
pop rax                                           ;Ditto
pop rax                                           ;Ditto
pop r11                                           ;Restore value to r11
pop rbx                                           ;Restore value to rbx
pop rax                                           ;Restore value to rax
pop r9                                            ;Restore value to r9
pop r8                                            ;Restore value to r8
pop rcx                                           ;Restore value to rcx
pop rdx                                           ;Restore value to rdx
pop rsi                                           ;Restore value to rsi
pop rdi                                           ;Restore value to rdi
;
;A matter of speed: The first three pops immediately above are present in order to remove three masks from the top of the
;stack.  No value is restored.  The three pops could have been accomplished faster using the single instruction:
;"sub qword rsp, 24"  .  The 24 comes from 3 pops of 8 bytes each.  The use of 'pops' to 'clean up' the stack gives the 
;programmer the ability to easily count the number of pops and the number of pushes in a subprogram.  Immediately before
;the return the two counts must be equal.  Subtracting from the rsp tends to obscure the true number of pops.

;There still remains rflags on top of the stack.  The original value of rflags is restored here.
;Now the number of 8-byte pushes equals the number of 8-byte pops.
popf                                              ;Instruction for popping and placing data into rflags

;It is time to leave this program.
ret 8                                             ;Return to address on top of stack and add 8 to rsp.
;End of showregisterssubprogram
;
;=======================================================================================================================
;
;Program: showstacksubprogram
;Purpose: Show the current state of the X86-64 stack.
;This program is called by the macro code inside the file debug.inc.
;A program should bring in the debug.inc into an application program via a statement such as
;%include "debug.inc"
;
;File name: debug.asm
;Language: X86-64
;Usage: CPSC240
;Author: F. Holliday
;Last update: 20120129

;Assemble: nasm -f elf64 -l debug.lis -o debug.o debug.asm
;
;Concerning the two pointers rbp and rsp.  The system stack, sometimes called the integer stack, is a built-in stack of 
;quadwords.  (Don't confuse this stack with the floating point stack.)  The pointer rsp always points to the top of the
;stack.  The pointer rbp is optional meaning that a programmer may use it or disregard it completely.  The most common
;use of the rbp is to point to the start of a new activation record.  An activation record is created when a subprogram
;is called, and it is destroyed when the subprogram returns.
;
;Important:  This program is built on rbp.  That means this program treats rbp as the top of the stack.  When calling
;this program it requires three parameters: an arbitrary integer, the number of qwords outside of the stack to be
;displayed, and the number of qwords inside the stack to be displayed.  Separator commas are placed after the first
;and second parameters.  Example call:  dumpstack 59, 4, 10
;

;Set constants via assembler directives
%define qwordsize qword 8                                   ;8 bytes

segment .data                                               ;This segment declares initialized data

specifierunsignedlonginteger10 db "r11 is %lu", 10, 0 ;Remove this declaration later

stackheadformat db "Stack Dump # %d:  ", 
                db "rbp = %016lx rsp = %016lx", 10, 
                db "Offset    Address           Value", 10, 0

stacklineformat db "%+5d  %016lx  %016lx", 10, 0

segment .bss                                                ;This segment declares uninitialized data
    ;This segment is empty
;
segment .text
global showstacksubprogram

extern printf

showstacksubprogram:                                        ;A place where execution begins when this program is called.

;Save the values in registers
pushf
push rdi
push rsi
push rdx
push rcx
push r8
push r9
push rax
push r11                                                    ;r11 is a special case related to printf

;Follow the CCC-64 protocol to set up the output of the dump stack header
mov qword rdi, stackheadformat
mov qword rsi, [rsp+10*8]                                   ;Arbitrary number passed in from caller
mov qword rdx, [rsp+13*8]                                   ;Retrieve the value of rbp
mov qword rcx, [rsp+14*8]                                   ;Retrieve the value of rsp
mov qword rax, 0
call printf

;Retrieve from the stack the number of qwords within the stack to be displayed
mov qword r13, [rsp+12*8]                         ;r13 will serve as loop counter variable
;Retrieve from the stack the number of qwords outside the stack to be displayed
mov qword r14, [rsp+11*8]                         ;r14 will help define the loop termination condition
neg r14                                           ;Negate r14.  Now r14 contains a negative integer

;Setup rbx as value in column 1 of the output.
mov qword rax, [rsp+12*8]                         ;Retrieve from the stack the number of qwords within the stack to be displayed.
mov qword r12, 8                                  ;Temporarily store 8 in r12
mul r12                                           ;Multiply rax by 8 bytes per qword
mov qword rbx, rax                                ;Save the product in rbx (column 1 of output)

;Retrieve from the stack the original value of rbp; r10 will be the counter for the 2nd column of output
mov qword r10, [rsp+13*8]
add r10, rbx

beginloop:
;Confirm correctness to this point
;Follow the CCC-64 protocol to set up the output of one quadword of memory
mov       rdi, stacklineformat
mov qword rsi, rbx
mov qword rdx, r10                                          ;r10 stores the addressalready contains the original value from rbp
mov qword rcx, [rdx]                                        ;Place contents of memory into rcx
mov qword rax, 0
call printf

;Move to next qword in the stack closer to top
sub rbx, 8
sub r10, 8
dec r13                                                     ;r13 is loop counter

;Check for loop termination condition
cmp r13, r14                                                ;Compare loop variable r13 with terminating value r14
jge beginloop                                               ;Iterate if r13 >= r14

;Confirm correctness to this point
;Follow the CCC-64 protocol to set up the output of one quadword of memory
;mov       rdi, stacklineformat
;mov qword rsi, rbx
;mov qword rdx, r10                                         ;rdx already contains the original value from rbp
;mov qword rcx, [rdx]                                       ;Place contents of memory into rcx
;mov qword rax, 0
;call printf

;Move to next qword in the stack closer to top
;sub rbx, 8
;sub r10, 8

;Confirm correctness to this point
;Follow the CCC-64 protocol to set up the output of one quadword of memory
;mov       rdi, stacklineformat
;mov qword rsi, rbx
;mov qword rdx, r10                                         ;rdx already contains the original value from rbp
;mov qword rcx, [rdx]                                       ;Place contents of memory into rcx
;mov qword rax, 0
;call printf

;Move to next qword in the stack closer to top
;sub rbx, 8
;sub r10, 8

;Confirm correctness to this point
;Follow the CCC-64 protocol to set up the output of one quadword of memory
;mov       rdi, stacklineformat
;mov qword rsi, rbx
;mov qword rdx, r10                                         ;rdx already contains the original value from rbp
;mov qword rcx, [rdx]                                       ;Place contents of memory into rcx
;mov qword rax, 0
;call printf

;Move to next qword in the stack closer to top
;sub rbx, 8
;sub r10, 8

;Confirm correctness to this point
;Follow the CCC-64 protocol to set up the output of one quadword of memory
;mov       rdi, stacklineformat
;mov qword rsi, rbx
;mov qword rdx, r10                                         ;rdx already contains the original value from rbp
;mov qword rcx, [rdx]                                       ;Place contents of memory into rcx
;mov qword rax, 0
;call printf

;Move to next qword in the stack closer to top
;sub rbx, 8
;sub r10, 8

;Confirm correctness to this point
;Follow the CCC-64 protocol to set up the output of one quadword of memory
;mov       rdi, stacklineformat
;mov qword rsi, rbx
;mov qword rdx, r10                                         ;rdx already contains the original value from rbp
;mov qword rcx, [rdx]                                       ;Place contents of memory into rcx
;mov qword rax, 0
;call printf

;Move to next qword in the stack closer to top
;sub rbx, 8
;sub r10, 8

;Confirm correctness to this point
;Follow the CCC-64 protocol to set up the output of one quadword of memory
;mov       rdi, stacklineformat
;mov qword rsi, rbx
;mov qword rdx, r10                                         ;rdx already contains the original value from rbp
;mov qword rcx, [rdx]                                       ;Place contents of memory into rcx
;mov qword rax, 0
;call printf

;Move to next qword in the stack closer to top
;sub rbx, 8
;sub r10, 8

;Confirm correctness to this point
;Follow the CCC-64 protocol to set up the output of one quadword of memory
;mov       rdi, stacklineformat
;mov qword rsi, rbx
;mov qword rdx, r10                                         ;rdx already contains the original value from rbp
;mov qword rcx, [rdx]                                       ;Place contents of memory into rcx
;mov qword rax, 0
;call printf

;Move to next qword in the stack closer to top
;sub rbx, 8
;sub r10, 8

;Confirm correctness to this point
;Follow the CCC-64 protocol to set up the output of one quadword of memory
;mov       rdi, stacklineformat
;mov qword rsi, rbx
;mov qword rdx, r10                                         ;rdx already contains the original value from rbp
;mov qword rcx, [rdx]                                       ;Place contents of memory into rcx
;mov qword rax, 0
;call printf

;Reverse the previous pushes
pop r11
pop rax
pop r9
pop r8
pop rcx
pop rdx
pop rsi
pop rdi
;There still remains rflags on top of the stack.  The original value of rflags is restored here.
;Now the number of 8-byte pushes equals the number of 8-byte pops.
popf                                                        ;Instruction for popping and placing data into rflags
;
;It is time to leave this program.
ret 40                                                      ;Return to address on top of stack and add 5*8 to rsp.
;End of showstacksubprogram

;=======================================================================================================================
;
;Program: showfpusubprogram
;Purpose: Show the current state of the FPU87 stack of registers.  Each member of the stack is an individual 10-bytes register in FPU87 
;extended format.
;This program is called by the macro code inside the file debug.inc.
;A program should bring in the debug.inc into an application program via a statement such as
;%include "debug.inc"
;
;File name: debug.asm
;Language: X86-64
;Usage: CPSC240
;Author: F. Holliday
;Last update: 20120229

;Assemble: nasm -f elf64 -l debug.lis -o debug.o debug.asm

;Set constants via assembler directives
%define qwordsize 8                                         ;8 bytes

segment .data                                               ;This segment declares initialized data

intro db "FPU87 stack values # %d:", 10, 0
stringformat db "%s", 0
columnheadings db "Register   Extended number     Quadword number", 10, 0
st7format db "   st7   %04x%016lx  %016lx", 10, 0
st6format db "   st6   %04x%016lx  %016lx", 10, 0
st5format db "   st5   %04x%016lx  %016lx", 10, 0
st4format db "   st4   %04x%016lx  %016lx", 10, 0
st3format db "   st3   %04x%016lx  %016lx", 10, 0
st2format db "   st2   %04x%016lx  %016lx", 10, 0
st1format db "   st1   %04x%016lx  %016lx", 10, 0
st0format db "   st0   %04x%016lx  %016lx", 10, 0
farewell db "End of FPU87 stack dump", 10, 0
;newline db 10, 0

segment .bss                                                ;This segment declares uninitialized data
    ;This segment is empty
;
segment .text
global showfpusubprogram

extern printf

showfpusubprogram:                                ;A place where execution begins when this program is called.

;Safe programming practice: save all the data that may possibly be modified within this subprogram
push rdi                                                    ;This program protects only the values of registers used in this program.
push rsi                                                    ;Yes, rax and rsp are used in this program, but for various reasons their values
push rdx                                                    ;are not deemed suitable for saving.
push rcx
push rbp

;Output the introductory message
mov qword rdi, intro                                        ;This is elementary.  The CCC registers rdi, rsi are used.
mov qword rsi, [rsp+6*qwordsize]                            ;6 = #pushes + 1; 48 bytes = 6*8 bytes per quadword
mov qword rax, 0                                            ;rax contains 0 as a special signal to the called function
call printf

;Output the column headings
mov qword rdi, stringformat
mov qword rsi, columnheadings
mov qword rax, 0
call printf
;
;= = = = = = Begin instructions to output st7 = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
;
fxch st7                                                    ;Swap st7 and st0

;Copy the number in st0 to memory.
mov qword rax, 0                                            ;Create 8 bytes of zeros for pushing onto the integer stack.
push rax                                                    ;Push 8 bytes of zeros.
push rax                                                    ;Push 8 more bytes for a total of 16 bytes of available space in memory.
;
;The instruction "fst tword [rsp]" does not assemble.  Therefore, we accomplish the same thing by popping the FPU87 stack into memory at the 
;integer stack followed by pushing that same number back onto the FPU87 stack.  Sounds confusing, but the next two instructions do the job.
fstp tword [rsp]                                            ;Important: this is an instruction acting on an extended fp number.
fld tword [rsp]                                             ;Ditto
;
;Perform the setup prior to output of the data about st7
mov rdi, st7format                                          ;This defines the appearance of one line of output
mov qword rsi, [rsp+8]                                      ;Obtain the most significant two bytes of the 10-byte extended number
mov qword rdx, [rsp]                                        ;Obtain the least significant eight bytes of the 10-byte extended number
push qword 0                                                ;We cannot copy st0 directly to rcx.  The data value must pass through memory.
fst qword [rsp]                                             ;Copy st0 to 8-bytes on top of the integer stack
pop rcx                                                     ;Pop those 8-bytes into rcx which is the 4th standard parameter according to CCC64.
mov qword rax, 0                                            ;This is mandatory when printf uses only integer registers.
call printf
;
pop rax                                                     ;Earlier pushes should be reversed as soon as the purpose for those pushes is
pop rax                                                     ;no longer present.
;
fxch st7                                                    ;Return the outputted value to its original location

;= = = = = = Begin instructions to output st6 = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 

fxch st6                                                    ;Swap st6 and st0

;Copy the number in st0 to memory.
mov qword rax, 0                                            ;Create 8 bytes of zeros for pushing onto the integer stack.
push rax                                                    ;Push 8 bytes of zeros.
push rax                                                    ;Push 8 more bytes for a total of 16 bytes of available space in memory.
;
;The instruction "fst tword [rsp]" does not assemble.  Therefore, we accomplish the same thing by popping the FPU87 stack into memory at the 
;integer stack followed by pushing that same number back onto the FPU87 stack.  Sounds confusing, but the next two instructions do the job.
fstp tword [rsp]                                            ;Important: this is an instruction acting on an extended fp number.
fld tword [rsp]                                             ;Ditto
;
;Perform the setup prior to output of the data about st7
mov rdi, st6format                                          ;This defines the appearance of one line of output
mov qword rsi, [rsp+8]                                      ;Obtain the most significant two bytes of the 10-byte extended number
mov qword rdx, [rsp]                                        ;Obtain the least significant eight bytes of the 10-byte extended number
push qword 0                                                ;We cannot copy st0 directly to rcx.  The data value must pass through memory.
fst qword [rsp]                                             ;Copy st0 to 8-bytes on top of the integer stack
pop rcx                                                     ;Pop those 8-bytes into rcx which is the 4th standard parameter according to CCC64.
mov qword rax, 0                                            ;This is mandatory when printf uses only integer registers.
call printf
;
pop rax                                                     ;Earlier pushes should be reversed as soon as the purpose for those pushes is
pop rax                                                     ;no longer present.
;
fxch st6

;= = = = = = Begin instructions to output st5 = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 

fxch st5                                                    ;Swap st5 and st0

;Copy the number in st0 to memory.
mov qword rax, 0                                            ;Create 8 bytes of zeros for pushing onto the integer stack.
push rax                                                    ;Push 8 bytes of zeros.
push rax                                                    ;Push 8 more bytes for a total of 16 bytes of available space in memory.
;
;The instruction "fst tword [rsp]" does not assemble.  Therefore, we accomplish the same thing by popping the FPU87 stack into memory at the 
;integer stack followed by pushing that same number back onto the FPU87 stack.  Sounds confusing, but the next two instructions do the job.
fstp tword [rsp]                                            ;Important: this is an instruction acting on an extended fp number.
fld tword [rsp]                                             ;Ditto
;
;Perform the setup prior to output of the data about st7
mov rdi, st5format                                          ;This defines the appearance of one line of output
mov qword rsi, [rsp+8]                                      ;Obtain the most significant two bytes of the 10-byte extended number
mov qword rdx, [rsp]                                        ;Obtain the least significant eight bytes of the 10-byte extended number
push qword 0                                                ;We cannot copy st0 directly to rcx.  The data value must pass through memory.
fst qword [rsp]                                             ;Copy st0 to 8-bytes on top of the integer stack
pop rcx                                                     ;Pop those 8-bytes into rcx which is the 4th standard parameter according to CCC64.
mov qword rax, 0                                            ;This is mandatory when printf uses only integer registers.
call printf
;
pop rax                                                     ;Earlier pushes should be reversed as soon as the purpose for those pushes is
pop rax                                                     ;no longer present.
;
fxch st5

;= = = = = = Begin instructions to output st4 = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 

fxch st4                                                    ;Swap st4 and st0

;Copy the number in st0 to memory.
mov qword rax, 0                                            ;Create 8 bytes of zeros for pushing onto the integer stack.
push rax                                                    ;Push 8 bytes of zeros.
push rax                                                    ;Push 8 more bytes for a total of 16 bytes of available space in memory.
;
;The instruction "fst tword [rsp]" does not assemble.  Therefore, we accomplish the same thing by popping the FPU87 stack into memory at the 
;integer stack followed by pushing that same number back onto the FPU87 stack.  Sounds confusing, but the next two instructions do the job.
fstp tword [rsp]                                            ;Important: this is an instruction acting on an extended fp number.
fld tword [rsp]                                             ;Ditto
;
;Perform the setup prior to output of the data about st7
mov rdi, st4format                                          ;This defines the appearance of one line of output
mov qword rsi, [rsp+8]                                      ;Obtain the most significant two bytes of the 10-byte extended number
mov qword rdx, [rsp]                                        ;Obtain the least significant eight bytes of the 10-byte extended number
push qword 0                                                ;We cannot copy st0 directly to rcx.  The data value must pass through memory.
fst qword [rsp]                                             ;Copy st0 to 8-bytes on top of the integer stack
pop rcx                                                     ;Pop those 8-bytes into rcx which is the 4th standard parameter according to CCC64.
mov qword rax, 0                                            ;This is mandatory when printf uses only integer registers.
call printf
;
pop rax                                                     ;Earlier pushes should be reversed as soon as the purpose for those pushes is
pop rax                                                     ;no longer present.
;
fxch st4

;= = = = = = Begin instructions to output st3 = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 

fxch st3                                                    ;Swap st3 and st0

;Copy the number in st0 to memory.
mov qword rax, 0                                            ;Create 8 bytes of zeros for pushing onto the integer stack.
push rax                                                    ;Push 8 bytes of zeros.
push rax                                                    ;Push 8 more bytes for a total of 16 bytes of available space in memory.
;
;The instruction "fst tword [rsp]" does not assemble.  Therefore, we accomplish the same thing by popping the FPU87 stack into memory at the 
;integer stack followed by pushing that same number back onto the FPU87 stack.  Sounds confusing, but the next two instructions do the job.
fstp tword [rsp]                                            ;Important: this is an instruction acting on an extended fp number.
fld tword [rsp]                                             ;Ditto
;
;Perform the setup prior to output of the data about st7
mov rdi, st3format                                          ;This defines the appearance of one line of output
mov qword rsi, [rsp+8]                                      ;Obtain the most significant two bytes of the 10-byte extended number
mov qword rdx, [rsp]                                        ;Obtain the least significant eight bytes of the 10-byte extended number
push qword 0                                                ;We cannot copy st0 directly to rcx.  The data value must pass through memory.
fst qword [rsp]                                             ;Copy st0 to 8-bytes on top of the integer stack
pop rcx                                                     ;Pop those 8-bytes into rcx which is the 4th standard parameter according to CCC64.
mov qword rax, 0                                            ;This is mandatory when printf uses only integer registers.
call printf
;
pop rax                                                     ;Earlier pushes should be reversed as soon as the purpose for those pushes is
pop rax                                                     ;no longer present.
;
fxch st3

;= = = = = = Begin instructions to output st2 = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 

fxch st2                                                    ;Swap st2 and st0

;Copy the number in st0 to memory.
mov qword rax, 0                                            ;Create 8 bytes of zeros for pushing onto the integer stack.
push rax                                                    ;Push 8 bytes of zeros.
push rax                                                    ;Push 8 more bytes for a total of 16 bytes of available space in memory.
;
;The instruction "fst tword [rsp]" does not assemble.  Therefore, we accomplish the same thing by popping the FPU87 stack into memory at the 
;integer stack followed by pushing that same number back onto the FPU87 stack.  Sounds confusing, but the next two instructions do the job.
fstp tword [rsp]                                            ;Important: this is an instruction acting on an extended fp number.
fld tword [rsp]                                             ;Ditto
;
;Perform the setup prior to output of the data about st7
mov rdi, st2format                                          ;This defines the appearance of one line of output
mov qword rsi, [rsp+8]                                      ;Obtain the most significant two bytes of the 10-byte extended number
mov qword rdx, [rsp]                                        ;Obtain the least significant eight bytes of the 10-byte extended number
push qword 0                                                ;We cannot copy st0 directly to rcx.  The data value must pass through memory.
fst qword [rsp]                                             ;Copy st0 to 8-bytes on top of the integer stack
pop rcx                                                     ;Pop those 8-bytes into rcx which is the 4th standard parameter according to CCC64.
mov qword rax, 0                                            ;This is mandatory when printf uses only integer registers.
call printf
;
pop rax                                                     ;Earlier pushes should be reversed as soon as the purpose for those pushes is
pop rax                                                     ;no longer present.
;
fxch st2

;= = = = = = Begin instructions to output st1 = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 

fxch st1                                                    ;Swap st1 and st0

;Copy the number in st0 to memory.
mov qword rax, 0                                            ;Create 8 bytes of zeros for pushing onto the integer stack.
push rax                                                    ;Push 8 bytes of zeros.
push rax                                                    ;Push 8 more bytes for a total of 16 bytes of available space in memory.
;
;The instruction "fst tword [rsp]" does not assemble.  Therefore, we accomplish the same thing by popping the FPU87 stack into memory at the 
;integer stack followed by pushing that same number back onto the FPU87 stack.  Sounds confusing, but the next two instructions do the job.
fstp tword [rsp]                                            ;Important: this is an instruction acting on an extended fp number.
fld tword [rsp]                                             ;Ditto
;
;Perform the setup prior to output of the data about st7
mov rdi, st1format                                          ;This defines the appearance of one line of output
mov qword rsi, [rsp+8]                                      ;Obtain the most significant two bytes of the 10-byte extended number
mov qword rdx, [rsp]                                        ;Obtain the least significant eight bytes of the 10-byte extended number
push qword 0                                                ;We cannot copy st0 directly to rcx.  The data value must pass through memory.
fst qword [rsp]                                             ;Copy st0 to 8-bytes on top of the integer stack
pop rcx                                                     ;Pop those 8-bytes into rcx which is the 4th standard parameter according to CCC64.
mov qword rax, 0                                            ;This is mandatory when printf uses only integer registers.
call printf
;
pop rax                                                     ;Earlier pushes should be reversed as soon as the purpose for those pushes is
pop rax                                                     ;no longer present.
;
fxch st1

;= = = = = = Begin instructions to output st0 = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 

;There is no swapping of registers because the number to be outputted is already in st0

;Copy the number in st0 to memory.
mov qword rax, 0                                            ;Create 8 bytes of zeros for pushing onto the integer stack.
push rax                                                    ;Push 8 bytes of zeros.
push rax                                                    ;Push 8 more bytes for a total of 16 bytes of available space in memory.
;
;The instruction "fst tword [rsp]" does not assemble.  Therefore, we accomplish the same thing by popping the FPU87 stack into memory at the 
;integer stack followed by pushing that same number back onto the FPU87 stack.  Sounds confusing, but the next two instructions do the job.
fstp tword [rsp]                                            ;Important: this is an instruction acting on an extended fp number.
fld tword [rsp]                                             ;Ditto
;
;Perform the setup prior to output of the data about st7
mov rdi, st0format                                          ;This defines the appearance of one line of output
mov qword rsi, [rsp+8]                                      ;Obtain the most significant two bytes of the 10-byte extended number
mov qword rdx, [rsp]                                        ;Obtain the least significant eight bytes of the 10-byte extended number
push qword 0                                                ;We cannot copy st0 directly to rcx.  The data value must pass through memory.
fst qword [rsp]                                             ;Copy st0 to 8-bytes on top of the integer stack
pop rcx                                                     ;Pop those 8-bytes into rcx which is the 4th standard parameter according to CCC64.
mov qword rax, 0                                            ;This is mandatory when printf uses only integer registers.
call printf
;
pop rax                                                     ;Earlier pushes should be reversed as soon as the purpose for those pushes is
pop rax                                                     ;no longer present.
;
;= = = = = = End of data output = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
          
;Say good-bye                                               ;Finally, we arrive at the end of this little program.
mov qword rdi, stringformat                                 ;A little good-bye message will be outputted.
mov qword rsi, farewell
mov qword rax, 0
call printf

;Restore the data to original values                        ;Besure these pops are in reverse order of the earlier pushes.
pop rbp
pop rcx
pop rdx
pop rsi
pop rdi

mov qword rax, 0                                            ;Return value 0 indicates successful conclusion.
ret 8                                                       ;Return to the address on top of the stack and then discard one qword from the top of the stack.
;End of showfpusubprogram 
;=======================================================================================================================





