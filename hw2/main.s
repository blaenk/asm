; Author: Jorge Pena
; Email: blaenkdenum@csu.fullerton.edu
; Course: CPSC240
; File: main.s
; Purpose: this subprogram uses various other subprograms written in both assembly and C to
;   perform all kinds of operations on two arrays

extern printf
extern scanf

extern readints     ; this subprogram reads in the array integers
extern writeints    ; this subprogram prints out the array integers
extern addvectors   ; this subprogram adds the two arrays together
extern sortarray    ; this subprogram sorts the sum vector resulting from addvectors
extern dotprod      ; this subprogram finds the dotproduct of both arrays by using two other subprograms

segment .data
  ; these are the welcome prompts and goodbye messages respectively
  welcome db "Welcome to array processing for integer data", 10, 0
  goodbye db "I hope you enjoyed my fast array program as much as I enjoyed making it.", 10, 0

  ; these are the prompts asking the user to initiate data input for each array
  firstarrayprompt db "Enter data for the first array: ", 0
  secondarrayprompt db "Enter data for the second array. For correct results you must enter exactly %li values: ", 0

  ; these are miscellaneous messages used to print out results of array operations
  arraymsg db "Your array is ", 0
  summsg db "The sum of the arrays is ", 0
  sortedmsg db "The sorted array is ", 0
  dotprodmsg db "The dot product of the two arrays is: %li", 10, 0

segment .bss
  firstarray resq 20    ; we have to pre-allocate the arrays, since they're static. 20 should be big enough
  secondarray resq 20   ; the second array should be the same maximum size
  summedarray resq 20   ; same with the array sum result

  firstsize resq 1      ; this will hold the length of the first array input
  secondsize resq 1     ; the length of the second array

  dotproduct resq 1     ; this will hold the returned dotproduct from the call to dotprod

segment .text
  global maindriver

maindriver:
  xor rbx, rbx
  mov qword rax, 0
  mov rdi, welcome    ; welcome the user with the message
  call printf

  ; first array
  mov qword rax, 0
  mov rdi, firstarrayprompt   ; ask the user to initiate input for the first array
  call printf

  mov qword rax, 0
  mov rdi, firstarray   ; the values input will go to the first array
  call readints         ; use the readints subprogram to read in as many numbers the user finds necessary

  mov qword [firstsize], rax    ; readints subprogram returns the size of the array that was input. store in firstsize

  ; output the array message
  mov qword rax, 0
  mov rdi, arraymsg
  call printf

  ; use writeints subprogram to output the actual array elements
  mov qword rax, 0
  mov qword rdi, firstarray     ; give it the array to print
  mov qword rsi, [firstsize]    ; give it the length of the array so it can safely iterate over it
  call writeints

  ; second array
  mov qword rax, 0
  mov rdi, secondarrayprompt  ; ask the user to initiate data input of the second array
  mov rsi, [firstsize]        ; recommend a size of the data input (length of first array) for optimal results
  call printf

  ; use the readints subprogram to read in the elements of the array
  mov qword rax, 0
  mov rdi, secondarray   ; the input should go to the second array
  call readints

  mov qword [secondsize], rax ; the subprogram returns the length of the input array

  ; output the array message
  mov qword rax, 0
  mov rdi, arraymsg
  call printf

  ; use the writeints subprogram to print out the array elements
  mov qword rax, 0
  mov qword rdi, secondarray    ; give it the array to print
  mov qword rsi, [secondsize]   ; give it the length of the array so it can safely iterate
  call writeints

  ; use the addvectors subprogram to do component-wise summation of both vectors
  mov qword rax, 0
  mov rdi, firstarray     ; use the first array
  mov rsi, secondarray    ; and the second one
  mov rdx, summedarray    ; and store the component-wise sum in summedarray
  mov rcx, [firstsize]    ; give it the length for safe iteration
  call addvectors

  ; output the sum message
  mov qword rax, 0
  mov rdi, summsg
  call printf

  ; use the writeints subprogram to output the array elements
  mov qword rax, 0
  mov qword rdi, summedarray  ; the array to print is the summed array
  mov qword rsi, [firstsize]  ; give it the length of the array for safe iteration
  call writeints

  ; use the sortarray subprogram to sort the array in-place
  mov qword rax, 0
  mov qword rdi, summedarray  ; the array to sort is the summed array
  mov qword rsi, [firstsize]  ; give it the length of the array for safe iteration
  call sortarray

  ; print the array message
  mov qword rax, 0
  mov rdi, sortedmsg
  call printf

  ; use the writeints subprogram to print out the summed array elements, which are now sorted
  mov qword rax, 0
  mov qword rdi, summedarray  ; the newly sorted summed array
  mov qword rsi, [firstsize]  ; the length of the array for safe iteration
  call writeints

  ; use the dotprod subprogram to calculate the dotproduct of both arrays
  mov qword rax, 0
  mov rdi, firstarray     ; operate on the first array
  mov rsi, secondarray    ; and the second array
  mov rdx, [firstsize]    ; give the length of the array for safe iteration
  call dotprod

  ; the dot product itself is returned by the call to the subprogram, so check rax
  mov qword [dotproduct], rax   ; save the value into the dotproduct variable

  ; print the dot product
  mov qword rax, 0
  mov rdi, dotprodmsg     ; the dotproduct message
  mov rsi, [dotproduct]   ; the actual dotproduct
  call printf

  ; say goodbye
  mov qword rax, 0
  mov rdi, goodbye    ; the goodbye message
  call printf

  ; exit
  xor rax, rax    ; give a return code of 0
  ret
