# order of operations:
# nasm -f elf64 -l perimeter.lis -o perimeter.o perimeter.asm
# gcc -c -Wall -m64 -std=c99 -l triangle.lis -o triangle.o triangle.c
# gcc -m64 -o triangle.out perimeter.o triangle.o
CC=gcc

all: asgmt4

asgmt4: driver.o area.o
						$(CC) -m64 -o asgmt4.out driver.o area.o

driver.o: driver.c
				$(CC) -c -Wall -m64 -std=c99 -l driver.lis -o driver.o driver.c

area.o: area.s
				nasm -f elf64 -l area.lis -o area.o area.s

clean:
				rm -rf area.o driver.o area.lis asgmt4.out

