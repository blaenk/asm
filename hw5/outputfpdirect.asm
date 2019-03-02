;Editor: F. Holliday
;Email: activeprofessor
;Course: CPSC240
;Date last modified: April 4, 2012
;File: outputfpdirect.asm
;Purpose: Demonstrate how to output fp numbers stored in the FPU stack and obtain full 80-bit precision.
;
;Special thanks: Mr. De Pecol provided the original software from which this example was derived.  I simply edited his work.  I mainly removed some instructions
;unrelated to the issue of 80-bit I/O.  The key parts of this program are his work.
;
;Assemble:  nasm -f elf64 -l outputfpdirect.lis -o outputfpdirect.o outputfpdirect.asm
;
;The output of calling the assembler are files with extensions  .o and  .lis.
;The .o file is the object file to be used in the linking; the .lis is the assembler generated listing.
;
;Testing.  Is full 80-bit precision truly realized in this program?  Eighty-bit precision means accuracy through the first 19 decimal digits of output.
;You can make this test yourself.  Follow this link: http://en.wikipedia.org/wiki/Square_root_of_2  There you will find the square root of 2.0 computed to 40 or more
;decimal places of precision.  Specifically, you will find the following: sqrt(2.0)=1.4142 1356 2373 0950 4880 1688 7242 0969 8078 5696 7187 5376 9480 7317 6679 7379 9
;The separators have been added for readability.  Next run this program and enter 2.0 as test input.  Count how many decimal digits are correct in your output.  
;Remember to count decimal digits on both sides of the decimal point, that is, the first digit to be counted is the leading 1.
;
;===== Begin code area =====================================================================================================================
extern printf                                               ;External C function for printing 
;extern scanf                                               ;For keyboard input using the iso99 version
extern  __isoc99_scanf				            ;The new scanf

segment .data                                               ;Place initialized data here

welcome db "This program inputs an fp number and computes its square root while maintaining 80-bit precision", 10, 0
goodbye db "The calculation is finished. Goodbye.", 10, 0

promptforinput db "   Enter an fp number -- 80-bit precision is supported: ", 0
formatstringfp db "   You entered:        %30.25Lf ", 10, 0      ;This is important: be sure to use upper case 'L'.
resultsquareroot db "   The square root is: %30.25Lf ", 10, 0    ;Be sure to use upper case 'L'.
formatstringdata db "%s", 0
formatlongfloat   db "%Lf", 0                               ;Be sure to use upper case 'L'


segment .bss                                                ;Place un-initialized data here.


segment .text

global extendednumbers                                      ;extendednumbers is visible for other programs to link to.
extendednumbers:                                            ;Entry point.  Execution begins here.

       push      rbp				            ;Save point to the caller frame
       mov rbp,  rsp                                        ;Set our frame

;Save exactly those registers used in this program except rax.  One could save all registers at the expense of a little more runtime.
       push      rdi
       push      rsi
;Footnote: one should push an even number of 8-byte registers.  This maintains alignment on 16-byte boundaries.  That helps the I/O of fp numbers with more bits than 8 bytes.

;Show the welcome message  
       mov qword rax, 0                                     ;Zero is required
       mov       rdi, formatstringdata                      ;Prepare printf for string output
       mov       rsi, welcome                               ;Place starting address of output text into rsi
       call      printf                                     ;Display the message

       finit                                                ;Initialize the floating point unit 

;Request input of a single floating number
       mov qword rax, 0                                     ;Zero is required
       mov       rdi, formatstringdata                      ;Set the format for text ouput
       mov       rsi, promptforinput                        ;Provide printf with the text to output
       call      printf                                     ;Display prompt for input of a single fp number

;Read the input from KB
       mov qword rax, 0                                     ;Zero is required
       mov       rdi, formatlongfloat                       ;Tell scanf that it will input a long float.
       push qword 0                                         ;Reserve space on the integer stack for the incoming fp number.
       push qword 0                                         ;At least 10 bytes (80 bits) is needed, but 16 bytes (128 bits) are allocated for the new number
       mov  rsi, rsp                                        ;rsi now points to the available storage
       call __isoc99_scanf			            ;Use new scanf to get the FP input.  Question: Why is the new scanf better than the old one?

       fld tword [rsp]                                      ;Load (and push) the new FP number into the next FP register st0.

;Print the number just acquired: its value is still on the integer stack
       mov       rdi, formatstringfp                        ;Set up the format printf will use to output both text and a number
       mov qword rax, 1                                     ;One is required
       call      printf                                     ;Send the FP number to standard output -- probably the monitor
       pop rax					            ;Reverse one of the earlier pushes.
       pop rax                                              ;Reverse the other previous push.
;
;
;Compute the square root of the number in st0
       fsqrt                                                ;The square root now replaces the original number
;
;Output the computed square root
       mov       rdi, resultsquareroot                      ;Set up the format printf will use to output both text and the square root.
       mov qword rax, 1                                     ;1 FP number will be outputted
       push qword 0                                         ;Reserve space on the integer stack for the fp number that will be transferred from the FP stack
       push qword 0                                         ;Reserve a total of 16 bytes for the fp coming from the FP stack
       fstp tword [rsp]                                     ;Pop the fp number from the FP stack into the storage at [rsp]
       call      printf                                     ;Send the FP number to standard output -- probably the monitor
       pop rax					            ;Reverse one of the earlier pushes.
       pop rax                                              ;Reverse the other previous push.
;
;Prepare an exit message
       mov qword rax, 0                                     ;Zero is required
       mov       rdi, formatstringdata                      ;Prepare printf for string output
       mov       rsi, goodbye                               ;Pass message to printf for outputting
       call      printf                                     ;Show exit message
;
;Restore all registers
       pop       rsi
       pop       rdi
;
       mov  rsp, rbp                                        ;Restore the caller frame
       pop       rbp

       mov qword rax, 0                                     ;Return 0 to the caller.
       ret                                                  ;ret pops the stack taking away 8 bytes
;===== End of hw4main subprogram =========================================================


