#!/bin/bash
assert() {
  expected="$1"
  input="$2"

  ./ccompiler "$input" > tmp.s
  nasm -f elf64 -g -o tmp.o -l tmp.lts tmp.s && ld -m elf_x86_64 -o tmp tmp.o
  ./tmp
  actual="$?"

  if [ "$actual" = "$expected" ]; then
    echo "$input => $actual"
  else
    echo "$input => $expected expected, but got $actual"
    exit 1
  fi
}

# expected input
assert "25" "5*(2+3)"
assert "3" "(3+3)/2"
assert "3" "(1*(4+2)/2)"
assert "12" "4*(1*(4+2)/2)"

echo OK