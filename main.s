%macro print 0
  mov rax, 1        ;writeシステムコールの識別子
  mov rdi, 1        ;stdoutファイルディスクリプタ
  syscall
%endmacro

[SECTION .text]
  global _start     ;エントリーポイント
	
_start:
  ; 1行目
  mov	rdx,len1
  mov	rsi,msg1
  print
  
  ; 2行目
  mov	rdx,len2
  mov	rsi,msg2
  print

  ; 3行目
  mov	rdx,len3
  mov	rsi,msg3
  print

  ; 4行目
  mov	rdx,len4
  mov	rsi,msg4
  print

  ; 4行目
  mov	rdx,len5
  mov	rsi,msg5
  print

  ; exit呼び出し
  mov     rax, 60
  mov     rdi, 0
  syscall

[SECTION .data]
msg1 db '[SECTION .text]', 0xa  ; 「0xa」は\n
len1 equ $ - msg1
msg2 db '  global _start', 0xa
len2 equ $ - msg2
msg3 db '_start:', 0xa
len3 equ $ - msg3
msg4 db '        mov ebx, 0D42', 0xa
len4 equ $ - msg4
msg5 db '        mov eax, 1', 0xa
len5 equ $ - msg5
msg6 db '        int 0x80', 0xa ;exit呼び出し
len6 equ $ - msg6
