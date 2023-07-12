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
assert "2" "1*2*3/3"
assert "11" "5+3*2"
assert "15" "5+3*2+6/3*2"
assert "15" "5+3*2+7/3*2"

echo OK