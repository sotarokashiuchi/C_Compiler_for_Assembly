; rcxとraxの退避が必要
%macro print 1
  mov   rcx, 0x0
  mov   rax, %1

%%print_loop:
  cmp   byte [rax], 0x0
  je    %%print_done
  inc   rax
  inc   rcx         ; インクリメント
  jmp   %%print_loop
%%print_done:
  mov rax, 1        ; write
  mov rdi, 1        ; fd
  mov rsi, %1       ; *buf
  mov rdx, rcx      ; count
  syscall           ; write(fd, *buf, count)
%endmacro

; 関数呼び出し規約(整数) RAX funx1(RDI, RSI, RDX, RCX, R8, R9, スタック, スタック, スタック, スタック)
; syscall呼び出し規約 RAX RAX(RDI, RSI, RDX, r10, r8, r9)

[SECTION .text]
  global main       ;エントリーポイント
	
main:
  push  rbp
  mov   rbp, rsp

  mov   rax, rdi    ; 第一引数(argc)
  mov   rbx, rsi    ; 第二引数(argv[0])
  add   rbx, 0x8    ; 第二引数(argv[1])
  push  qword [rbx]

  ; 1行目
  print msg1
  print msg2
  print msg3
  print msg4
  print msg5
  print msg6
  print qword[rbp-8]
  print msg7
  print msg8

  ; 数値と文字列を変換する必要がある
  ; print ??

  print msg9

  mov rsp, rbp
  pop rbp

  mov rax, 60 ;exit syscall 識別子
  mov rdi, 0  ;引数1:終了ステータス
  syscall

[SECTION .data]
msg1 db       '[SECTION .text]', 0xa, 0x0  ; 「0xa」は\n
msg2 db 0x09,   'global _start', 0xa, 0x0
msg3 db         '_start:', 0xa, 0x0
msg4 db 0x09,   'mov rax, 0x1', 0xa, 0x0 ;write syscall 識別子
msg5 db 0x09,   'mov rdi, 0x1', 0xa, 0x0 ;引数1
msg6 db 0x09,   'mov rsi, "', 0x0        ;引数2:*buf
; 入力された文字列埋め込み
msg7 db '"', 0xa, 0x0
len7 equ $ - msg7
msg8 db 0x09, 'mov rdx, ', 0x0        ;引数3:count
len8 equ $ - msg8
; 文字数
msg9 db 0xa, 0x09, 'syscall', 0xa, 0x0 ;exit呼び出し
len9 equ $ - msg9

