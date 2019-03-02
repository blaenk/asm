# files
#   1. driver.c
#   2. main.s
#   3. readarray.cpp: reads in fp numbers into an array
#   4. outputarray.s: outputs fp numbers
#   5. sumarray.c: returns sum of values
#   6. getmin.s: returns smallest value
#   7. getmax:.c returns largest value
#   8. getmean.cpp: returns mean
#   9. getvariance.cpp: returns variance
#   		note: either this gets passed the mean, or this calls getmean
#   10. getstandarddeviation.s: returns standard deviation (double, so xmm0)
#   		note: either this gets passed the variance and size of array, or calls getvariance
#   11. getgeometricmean.c: returns geometric mean of sample. use absolute value of elements
#   12. appendarrays.s: appends two arrays, both arrays are passed, new array returned

CC = gcc
CXX = g++
AS = nasm

# elf64
format = elf64

objs = driver.o main.o readarray.o outputarray.o sumarray.o getmin.o getmax.o getmean.o getvariance.o getstandarddeviation.o getgeometricmean.o appendarrays.o

asgmt6: $(objs)
		$(CXX) -m64 -o $@ $+
		echo asgmt6 : make complete

%.o: %.c
		$(CC) -c -Wall -m64 -std=c99 $<

%.o: %.cpp
		$(CXX) -c -Wall -m64 $<

%.o: %.s
		$(AS) -f $(format) $<

driver.o: driver.c
main.o: main.s
readarray.o: readarray.cpp
outputarray.o: outputarray.s
sumarray.o: sumarray.c
getmin.o: getmin.s
getmax.o: getmax.c
getmean.o: getmean.cpp
getvariance.o: getvariance.cpp
getstandarddeviation.o: getstandarddeviation.s
getgeometricmean.o: getgeometricmean.c
appendarrays.o: appendarrays.s

.PHONY: clean
clean:
		rm $(objs)
		echo clean : make complete

