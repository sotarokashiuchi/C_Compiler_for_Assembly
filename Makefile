ccompiler: ./src/main.s
	nasm -f elf64 -g -o main.o ./src/main.s
	cc -static -o ccompiler main.o

test: ccompiler
	./test.sh

clean:
	rm -f *.o tmp*

.PHONY: test clean