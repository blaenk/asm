;Macros for debugging
;File name: debug.inc
;
;Requirements: debug.asm must be assembled into debug.o

;======================================================================================================================

extern showregisterssubprogram

%macro showregisters 1
    push qword %1
    call showregisterssubprogram
    ;Question: Where is the pop corresponding to the push above?  Answer: In the ret statement.
%endmacro

;======================================================================================================================

extern showstacksubprogram

%macro dumpstack 3
    push rsp                                      ;Save the current value of rsp since rsp is very volatile
    push rbp                                      ;Save the current value of rbp for insurance
    push qword %3                                 ;number of qwords inside the stack
    push qword %2                                 ;number of qwords outside the stack
    push qword %1                                 ;an arbitrary integer created by the caller
    call showstacksubprogram
    ;Question: Where are the pops corresponding to three pushes above?  Answer: In the ret statement.
%endmacro

;======================================================================================================================

extern showfpusubprogram

%macro showfpuregisters 1
    push qword %1                                 ;Integer identifying this showing of the fpu registers.
    call showfpusubprogram
    ;Where are the pops corresponding to those pushes?
%endmacro

;======================================================================================================================

;Sample invoking of the programs.  The calling program will have statements like these:

;showregisters 15

;showregisters 985

;dumpstack 2000, 2, 5

;dumpstack 35, 3, 8

;showfpuregisters 50

;showfpuregisters 133

;dumpstack takes three parameters of which the first is a dummy.  The other two require one parameter which is always a dummy integer.

;To the 240 class:
;This debug set of subprograms was derived from the original work of Dr Paul Carter.  He made a similar set of subprograms that could be 
;easily included in any assembly program.  All of his work was written in X86-32m and unfortunately, he seems to have lost interest in 
;updating his work.  You can and probably should visit his website: http://www.drpaulcarter.com/pcasm/.  There you may download the
;original include files which he called "asm_io.inc" and "asm_io.asm".  They are inside a zip file.  He also has a free ebook there on X86-32 
;programming.  Yes, all the examples are 32-bit one, but the text description of instructions is still very helpful.  For instance, in his 
;ebook you can read a concise description of many of the FPU87 instructions, that is, those instructions that act on the st registers.  Yes, 
;I am aware that others have tried to update his work to become relevant to 64-bit programming, but I still like the original ebook.

;Thus, Dr Carter's work was the foundation for the debug.inc and debug.asm files you are now reading.  For the curious, you may wonder what 
;happens when an assembly program has to call a C++ function that requires more that 6 incoming parameters.  There is an example of passing
;9 parameters to printf in the "showregisterssubprogram", which is inside the file debug.asm.  Notice the registerformat1 requires 8 numeric
;values be passed to printf in addition to passing the string registerformat1 in rdi.  

;Testing.  The program to show fpu registers needs additional testing.  I tested it a modest number of times, and it appeared to produce correct
;values.  I consider it (showfpuregisters) to be a beta version.  If anyone in the class discovers erroneous output I certainly want to know 
;about.  When you discover an error do record your inputs and send them to me with a sample output.  This helps me re-produce the error, and 
;that helps the process of fixing the software.
