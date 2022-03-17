all: build run

build:
	nasm primes.asm -f elf64 -o primes.o
	gcc primes.o -nostdlib -Wall -o primes -no-pie

run:
	./primes
