CC=gcc

all: asgmt5

asgmt5: driver.o harmonic.o debug.o
				$(CC) -m64 -o asgmt5.out driver.o harmonic.o debug.o

debug.o: debug.asm
				nasm -f elf64 -l debug.list -o debug.o debug.asm

driver.o: driver.c
				$(CC) -c -Wall -m64 -std=c99 -l driver.lis -o driver.o driver.c

harmonic.o: harmonic.s
				nasm -f elf64 -l harmonic.lis -o harmonic.o harmonic.s

clean:
				rm -rf harmonic.o driver.o harmonic.lis asgmt5.out

