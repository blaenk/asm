# order of operations:
# nasm -f elf64 -l perimeter.lis -o perimeter.o perimeter.asm
# gcc -c -Wall -m64 -std=c99 -l triangle.lis -o triangle.o triangle.c
# gcc -m64 -o triangle.out perimeter.o triangle.o
CC=gcc

all: asgmt1

asgmt1: driver.o arithmetic.o
						$(CC) -m64 -o asgmt1.out driver.o arithmetic.o

driver.o: driver.c
				$(CC) -c -Wall -m64 -std=c99 -l driver.lis -o driver.o driver.c

arithmetic.o: arithmetic.s
				nasm -f elf64 -l arithmetic.lis -o arithmetic.o arithmetic.s

clean:
				rm -rf arithmetic.o driver.o arithmetic.lis asgmt1.out

