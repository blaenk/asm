CC=gcc
nasm=nasm -f elf64

all: asgmt2

asgmt2: driver.o main.o
	$(CC) -m64 -o asgmt2.out driver.o main.o readintarray.o writeintarray.o addvectors.o sortintarray.o dotproduct.o multiplyvectors.o sumarray.o

driver.o: driver.c main.o
	$(CC) -c -Wall -m64 -std=c99 -l driver.lis -o driver.o driver.c

main.o: main.s readintarray.o writeintarray.o addvectors.o sortintarray.o dotproduct.o
	$(nasm) -l main.lis -o main.o main.s

readintarray.o: readintarray.s
	$(nasm) -l readintarray.lis -o readintarray.o readintarray.s

writeintarray.o: writeintarray.s
	$(nasm) -l writeintarray.lis -o writeintarray.o writeintarray.s

addvectors.o: addvectors.s
	$(nasm) -l addvectors.lis -o addvectors.o addvectors.s

sortintarray.o: sortintarray.c
	$(CC) -c -Wall -m64 -std=c99 -l sortintarray.lis -o sortintarray.o sortintarray.c

dotproduct.o: dotproduct.s multiplyvectors.o sumarray.o
	$(nasm) -l dotproduct.lis -o dotproduct.o dotproduct.s

multiplyvectors.o: multiplyvectors.s
	$(nasm) -l multiplyvectors.lis -o multiplyvectors.o multiplyvectors.s

sumarray.o: sumarray.c
	$(CC) -c -Wall -m64 -std=c99 -l sumarray.lis -o sumarray.o sumarray.c

clean:
	rm -rfv *.o *.lis *.out

