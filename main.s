%macro print 0
  mov rax, 1        ;writeシステムコールの識別子
  mov rdi, 1        ;stdoutファイルディスクリプタ
  syscall
%endmacro

[SECTION .text]
   global _start     ;エントリーポイント
	
_start:
  ; 1行目
  mov	rdx,len1     ;message length
  mov	rsi,msg1     ;message to write
  print
  ; ; 1行目
  ; mov	edx,len1     ;message length
  ; mov	ecx,msg1     ;message to write
  ; print
  
  ; 2行目
  mov	rdx,len2     ;message length
  mov	rsi,msg2     ;message to write
  print

  ; 3行目
  mov	rdx,len3     ;message length
  mov	rsi,msg3     ;message to write
  print

  ; 4行目
  mov	rdx,len4     ;message length
  mov	rsi,msg4     ;message to write
  print

  ; 4行目
  mov	rdx,len5     ;message length
  mov	rsi,msg5     ;message to write
  print

  mov     rax, 60
  mov     rdi, 0
  syscall

[SECTION .data]
msg1 db '[SECTION .text]', 0xa ; 「0xa」は'\n'
len1 equ $ - msg1
msg2 db '  global _start', 0xa
len2 equ $ - msg2
msg3 db '_start:', 0xa
len3 equ $ - msg2
msg4 db '        mov rax, 42', 0xa
len4 equ $ - msg3
msg5 db '        ret', 0xa
len5 equ $ - msg4

   
; [SECTION .data]
; msg1 db '.intel_syntax noprefix', 0xa
; len1 equ $ - msg1
; msg2 db '.globl main', 0xa
; len2 equ $ - msg2
; msg3 db '        mov rax, 42', 0xa
; len3 equ $ - msg3
; msg4 db '        ret', 0xa
; len4 equ $ - msg4
