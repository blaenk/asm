; Author: Jorge Peña
; Email: blaenkdenum@csu.fullerton.edu
; Course: CPSC240
; Assignment: #6 Statistical Analysis
; Due: 2012-May-10
; File: statistics.s
; Purpose: be the main assembly program

; we use printf from the c library
extern printf

; here are the functions we have defined in separate files
extern readarray
extern outputarray
extern getsum
extern getmin
extern getmax
extern getmean
extern getvariance
extern getstandarddeviation
extern getgeometricmean
extern appendarrays

segment .data
  firstprompt db 10, "Please enter the first array.", 10, 0         ; ask for the first array
  secondprompt db 10, "Please enter the second array.", 10, 0       ; ask for the second array

  ; result messages
  firstoutput db 10, "First array statistical analysis", 10, 0      ; output the first array
  secondoutput db 10, "Second array statistical analysis", 10, 0    ; output the second array

  concatmsg db 10, "The concatenated array is", 10, 0               ; print the concatenated array
  arraymsg db "The array is", 10, 0                                 ; print the array
  
  resultmsg db "The %s is %-#15.15lf", 10, 0                        ; generic result message (e.g. for mean, max, etc.)

  ; result types
  sum db "sum", 0                                                   ; specific for sum
  min db "smallest value", 0                                        ; specific for min
  max db "largest value", 0                                         ; specific for max
  mean db "arithmetic mean", 0                                      ; specific for mean
  variance db "variance", 0                                         ; specific for variance
  standarddeviation db "standard deviation", 0                      ; specific for standard deviation
  geometricmean db "geometric mean", 0                              ; specific for geometric mean

  ; the conclusion
  goodbye db 10, "Statistical analysis will now terminate and return to the main driver.", 10, 0     ; goodbye message

segment .bss
  firstarray resq 1                             ; holds memory address of first array
  firstarraysize resq 1                         ; holds size of first array

  firstarraymean resq 1                         ; holds mean of first array
  firstarrayvariance resq 1                     ; holds variance of first array

  secondarray resq 1                            ; same as above for second array
  secondarraysize resq 1

  secondarraymean resq 1
  secondarrayvariance resq 1

  concatenatedarray resq 1                      ; same as above for concatenated array
  concatenatedarraysize resq 1

  concatenatedarraymean resq 1
  concatenatedarrayvariance resq 1

segment .text
  global statistics

statistics:
  push rbp                                      ; save the stack frame of the caller
  mov rbp, rsp                                  ; initiate a new stack frame

  mov qword rax, 0
  mov rdi, firstprompt                          ; ask for the first array
  call printf

  mov qword rax, 0                              ; function readarray
  mov rdi, firstarraysize                       ; find out how big the array is (pass by reference)
  call readarray                                ; read in the first array, address is returned

  mov [firstarray], rax                         ; save the address of the first array

  mov qword rax, 0
  mov rdi, secondprompt                         ; ask for the second array
  call printf

  mov qword rax, 0                              ; function readarray
  mov rdi, secondarraysize                      ; find out how big the array is (pass by reference)
  call readarray                                ; read in the first array, address is returned

  mov [secondarray], rax                        ; save the address of the second array

                                                ; SECTION: first array stat analysis
  mov qword rax, 0
  mov rdi, firstoutput                          ; tell user we're printing stats of first array
  call printf

  mov qword rax, 0
  mov rdi, arraymsg                             ; tell user the array follows
  call printf

  mov qword rax, 0                              ; function outputarray
  mov rdi, [firstarray]                         ; it takes the address of the array
  mov rsi, [firstarraysize]                     ; as well as the size
  call outputarray                              ; returns nothing

  mov qword rax, 0                              ; function getsum
  mov rdi, [firstarray]                         ; it takes the address of the array
  mov rsi, [firstarraysize]                     ; and the size of the array
  call getsum                                   ; returns the sum of the array elements

  mov qword rax, 1                              ; the min value is already in xmm0
  mov rdi, resultmsg                            ; print the result
  mov rsi, sum                                  ; of the sum
  call printf

  mov qword rax, 0                              ; function getmin
  mov rdi, [firstarray]                         ; it takes the address of the array
  mov rsi, [firstarraysize]                     ; and the size of the array
  call getmin                                   ; returns smallest value into xmm0

  mov qword rax, 1                              ; the min value is already in xmm0
  mov rdi, resultmsg                            ; print the result
  mov rsi, min                                  ; of the minimum value
  call printf

  mov qword rax, 0                              ; function getmax
  mov rdi, [firstarray]                         ; it takes the address of the array
  mov rsi, [firstarraysize]                     ; as well as the size
  call getmax                                   ; and returns largest value into xmm0

  mov qword rax, 1                              ; the max value is already in xmm0
  mov rdi, resultmsg                            ; print the result
  mov rsi, max                                  ; of the maximum value
  call printf

  mov qword rax, 0                              ; function getmean
  mov rdi, [firstarray]                         ; it takes the address of the array
  mov rsi, [firstarraysize]                     ; as well as the size
  call getmean                                  ; and returns the mean in xmm0

  movsd [firstarraymean], xmm0                  ; we need the mean for the variance, save it

  mov qword rax, 1                              ; mean is already in xmm0
  mov rdi, resultmsg                            ; print the result
  mov rsi, mean                                 ; of the mean
  call printf

  movsd xmm0, [firstarraymean]                  ; put the mean back into xmm0 to pass to getvariance

  mov qword rax, 1                              ; function getvariance
  mov rdi, [firstarray]                         ; pass it the address of the array
  mov rsi, [firstarraysize]                     ; as well as the size
  call getvariance                              ; and returns the variance in xmm0

  movsd [firstarrayvariance], xmm0              ; we need the variance for the standard deviation, save it

  mov qword rax, 1                              ; variance is already in xmm0
  mov rdi, resultmsg                            ; print out the result
  mov rsi, variance                             ; of the varaince
  call printf

  movsd xmm0, [firstarrayvariance]              ; put the variance back into xmm0 for getstandarddeviation

  mov qword rax, 1                              ; function getstandardeviation just needs the variance
  call getstandarddeviation                     ; which is already in xmm0, returns the standard deviation

  mov qword rax, 1                              ; the standard deviation is in xmm0
  mov rdi, resultmsg                            ; print the result
  mov rsi, standarddeviation                    ; of the standard deviation
  call printf

  mov qword rax, 0                              ; funciton getgeometricmean
  mov rdi, [firstarray]                         ; it takes the address of the array
  mov rsi, [firstarraysize]                     ; as well as the size of the array
  call getgeometricmean                         ; and returns the geometric mean into xmm0

  mov qword rax, 1                              ; the geometric mean is already in xmm0
  mov rdi, resultmsg                            ; print the result
  mov rsi, geometricmean                        ; of the geometric mean
  call printf

                                                ; SECTION: second array stat analysis
  mov qword rax, 0
  mov rdi, secondoutput                         ; tell user we're printing stats of second array
  call printf

  mov qword rax, 0
  mov rdi, arraymsg                             ; tell user the array follows
  call printf

  mov qword rax, 0                              ; function outputarray
  mov rdi, [secondarray]                        ; it takes the address of the array
  mov rsi, [secondarraysize]                    ; as well as the size
  call outputarray                              ; returns nothing

  mov qword rax, 0                              ; function getsum
  mov rdi, [secondarray]                         ; it takes the address of the array
  mov rsi, [secondarraysize]                     ; and the size of the array
  call getsum                                   ; returns the sum of the array elements

  mov qword rax, 1                              ; the min value is already in xmm0
  mov rdi, resultmsg                            ; print the result
  mov rsi, sum                                  ; of the sum
  call printf

  mov qword rax, 0                              ; function getmin
  mov rdi, [secondarray]                        ; it takes the address of the array
  mov rsi, [secondarraysize]                    ; and the size of the array
  call getmin                                   ; returns smallest value into xmm0

  mov qword rax, 1                              ; the min value is already in xmm0
  mov rdi, resultmsg                            ; print the result
  mov rsi, min                                  ; of the minimum value
  call printf

  mov qword rax, 0                              ; function getmax
  mov rdi, [secondarray]                        ; it takes the address of the array
  mov rsi, [secondarraysize]                    ; as well as the size
  call getmax                                   ; and returns largest value into xmm0

  mov qword rax, 1                              ; the max value is already in xmm0
  mov rdi, resultmsg                            ; print the result
  mov rsi, max                                  ; of the maximum value
  call printf

  mov qword rax, 0                              ; function getmean
  mov rdi, [secondarray]                        ; it takes the address of the array
  mov rsi, [secondarraysize]                    ; as well as the size
  call getmean                                  ; and returns the mean in xmm0

  movsd [secondarraymean], xmm0                 ; we need the mean for the variance, save it

  mov qword rax, 1                              ; mean is already in xmm0
  mov rdi, resultmsg                            ; print the result
  mov rsi, mean                                 ; of the mean
  call printf

  movsd xmm0, [secondarraymean]                 ; put the mean back into xmm0 to pass to getvariance

  mov qword rax, 1                              ; function getvariance
  mov rdi, [secondarray]                        ; pass it the address of the array
  mov rsi, [secondarraysize]                    ; as well as the size
  call getvariance                              ; and returns the variance in xmm0

  movsd [secondarrayvariance], xmm0             ; we need the variance for the standard deviation, save it

  mov qword rax, 1                              ; variance is already in xmm0
  mov rdi, resultmsg                            ; print out the result
  mov rsi, variance                             ; of the varaince
  call printf

  movsd xmm0, [secondarrayvariance]             ; put the variance back into xmm0 for getstandarddeviation

  mov qword rax, 1                              ; function getstandardeviation just needs the variance
  call getstandarddeviation                     ; which is already in xmm0, returns the standard deviation

  mov qword rax, 1                              ; the standard deviation is in xmm0
  mov rdi, resultmsg                            ; print the result
  mov rsi, standarddeviation                    ; of the standard deviation
  call printf

  mov qword rax, 0                              ; funciton getgeometricmean
  mov rdi, [secondarray]                        ; it takes the address of the array
  mov rsi, [secondarraysize]                    ; as well as the size of the array
  call getgeometricmean                         ; and returns the geometric mean into xmm0

  mov qword rax, 1                              ; the geometric mean is already in xmm0
  mov rdi, resultmsg                            ; print the result
  mov rsi, geometricmean                        ; of the geometric mean
  call printf

                                                ; SECTION concatenated array

  mov rdi, [firstarraysize]                     ; size of the concatenated array is
  add rdi, [secondarraysize]                    ; the sum of the size of the first and second array
  mov [concatenatedarraysize], rdi              ; store this size for later use

  mov qword rax, 0                              ; function append arrays
  mov rdi, [firstarray]                         ; takes the first array address
  mov rsi, [firstarraysize]                     ; the size of the first array
  mov rdx, [secondarray]                        ; the second array address
  mov rcx, [secondarraysize]                    ; the size of the second array
  call appendarrays                             ; and returns the address of the new array in rax

  mov [concatenatedarray], rax                  ; save the address of the new array from rax for later use

  mov qword rax, 0
  mov rdi, concatmsg                            ; print that this is the concatenated array
  call printf

  mov qword rax, 0                              ; function outputarray
  mov rdi, [concatenatedarray]                  ; takes the array address
  mov rsi, [concatenatedarraysize]              ; and the array size
  call outputarray

  mov qword rax, 0                              ; function getsum
  mov rdi, [concatenatedarray]                  ; it takes the address of the array
  mov rsi, [concatenatedarraysize]              ; and the size of the array
  call getsum                                   ; returns the sum of the array elements

  mov qword rax, 1                              ; the min value is already in xmm0
  mov rdi, resultmsg                            ; print the result
  mov rsi, sum                                  ; of the sum
  call printf

  mov qword rax, 0                              ; function getmin
  mov rdi, [concatenatedarray]                  ; it takes the address of the array
  mov rsi, [concatenatedarraysize]              ; and the size of the array
  call getmin                                   ; returns smallest value into xmm0

  mov qword rax, 1                              ; the min value is already in xmm0
  mov rdi, resultmsg                            ; print the result
  mov rsi, min                                  ; of the minimum value
  call printf

  mov qword rax, 0                              ; function getmax
  mov rdi, [concatenatedarray]                  ; it takes the address of the array
  mov rsi, [concatenatedarraysize]              ; as well as the size
  call getmax                                   ; and returns largest value into xmm0

  mov qword rax, 1                              ; the max value is already in xmm0
  mov rdi, resultmsg                            ; print the result
  mov rsi, max                                  ; of the maximum value
  call printf

  mov qword rax, 0                              ; function getmean
  mov rdi, [concatenatedarray]                  ; it takes the address of the array
  mov rsi, [concatenatedarraysize]              ; as well as the size
  call getmean                                  ; and returns the mean in xmm0

  movsd [concatenatedarraymean], xmm0           ; we need the mean for the variance, save it

  mov qword rax, 1                              ; mean is already in xmm0
  mov rdi, resultmsg                            ; print the result
  mov rsi, mean                                 ; of the mean
  call printf

  movsd xmm0, [concatenatedarraymean]           ; put the mean back into xmm0 to pass to getvariance

  mov qword rax, 1                              ; function getvariance
  mov rdi, [concatenatedarray]                  ; pass it the address of the array
  mov rsi, [concatenatedarraysize]              ; as well as the size
  call getvariance                              ; and returns the variance in xmm0

  movsd [concatenatedarrayvariance], xmm0       ; we need the variance for the standard deviation, save it

  mov qword rax, 1                              ; variance is already in xmm0
  mov rdi, resultmsg                            ; print out the result
  mov rsi, variance                             ; of the varaince
  call printf

  movsd xmm0, [concatenatedarrayvariance]       ; put the variance back into xmm0 for getstandarddeviation

  mov qword rax, 1                              ; function getstandardeviation just needs the variance
  call getstandarddeviation                     ; which is already in xmm0, returns the standard deviation

  mov qword rax, 1                              ; the standard deviation is in xmm0
  mov rdi, resultmsg                            ; print the result
  mov rsi, standarddeviation                    ; of the standard deviation
  call printf

  mov qword rax, 0                              ; funciton getgeometricmean
  mov rdi, [concatenatedarray]                  ; it takes the address of the array
  mov rsi, [concatenatedarraysize]              ; as well as the size of the array
  call getgeometricmean                         ; and returns the geometric mean into xmm0

  mov qword rax, 1                              ; the geometric mean is already in xmm0
  mov rdi, resultmsg                            ; print the result
  mov rsi, geometricmean                        ; of the geometric mean
  call printf

  mov qword rax, 0
  mov rdi, goodbye                              ; print the goodbye message
  call printf

  mov rsp, rbp                                  ; restore the caller's frame pointer
  pop rbp

  xor rax, rax                                  ; set the return value to 0
  ret                                           ; return to caller

