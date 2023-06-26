ccompiler: ./src/main.s
	nasm -f elf64 -g -o main.o -l main.lts ./src/main.s
	cc -static -o ccompiler main.o

test: ccompiler
	./test.sh

clean:
	rm -f *.o tmp* *.lts

.PHONY: test clean