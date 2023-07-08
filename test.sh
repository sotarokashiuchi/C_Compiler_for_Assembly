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
assert "4" "5+4-5"
assert "3" "3+5-5"

echo OK