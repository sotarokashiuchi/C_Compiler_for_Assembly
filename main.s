%macro print 0
  mov rax, 1        ;writeシステムコールの識別子
  mov rdi, 1        ;stdoutファイルディスクリプタ
  syscall           ; write(fd, *buf, count)
%endmacro

; 関数呼び出し規約(整数) RAX funx1(RDI, RSI, RDX, RCX, R8, R9, スタック, スタック, スタック, スタック)
; syscall呼び出し規約 RAX RAX(RDI, RSI, RDX, r10, r8, r9)

[SECTION .text]
  global main       ;エントリーポイント
	
main:
  push  rbp         ;ldリンカの場合_startがエントリーポイントのため、rbpレジスタを退避する必要はないが
  mov   rbp, rsp

  mov   rax, rdi    ; 第一引数(argc)
  mov   rbx, rsi    ; 第二引数(argv[0])
  add   rbx, 0x8    ; 第二引数(argv[1])
  push  qword [rbx]

  ; 1行目
  mov	rdx,len1
  mov	rsi,msg1
  print
  mov	rdx,len2
  mov	rsi,msg2
  print
  mov	rdx,len3
  mov	rsi,msg3
  print
  mov	rdx,len4
  mov	rsi,msg4
  print
  mov	rdx,len5
  mov	rsi,msg5
  print
  mov	rdx,len6
  mov	rsi,msg6
  print

  mov   rcx, 0x0
  mov   rax, qword [rbp-8]

.loop:
  cmp   byte [rax], 0x0
  je    .done
  inc   rax
  inc   rcx         ; インクリメント
  jmp   .loop

.done:
  push rcx
  mov   rsi, [rbp-8]; *buf
  mov   rdx, rcx    ; count
  print
  syscall

  mov	rdx,len7
  mov	rsi,msg7
  print
  mov	rdx,len8
  mov	rsi,msg8
  print

  mov   rsi, [rbp-16]; *buf
  mov   rdx, rcx    ; count
  print
  syscall

  mov	rdx,len9
  mov	rsi,msg9
  print

  mov rsp, rbp
  pop rbp          ;ldリンカの場合_startがエントリーポイントのため、rbpレジスタを退避する必要はないが
  ; exit呼び出し
  mov rax, 60 ;exit syscall 識別子
  mov rdi, 0  ;引数1:終了ステータス
  syscall

[SECTION .data]
msg1 db '[SECTION .text]', 0xa  ; 「0xa」は\n
len1 equ $ - msg1
msg2 db 0x09, 'global _start', 0xa
len2 equ $ - msg2
msg3 db '_start:', 0xa
len3 equ $ - msg3

msg4 db 0x09, 'mov rax, 0x1', 0xa ;write syscall 識別子
len4 equ $ - msg4
msg5 db 0x09, 'mov rdi, 0x1', 0xa ;引数1
len5 equ $ - msg5
msg6 db 0x09, 'mov rsi, "'        ;引数2:*buf
len6 equ $ - msg6
; 入力された文字列埋め込み
msg7 db '"', 0xa
len7 equ $ - msg7
msg8 db 0x09, 'mov rdx, '        ;引数3:count
len8 equ $ - msg8
; 文字数
msg9 db 0xa, 0x09, 'syscall', 0xa ;exit呼び出し
len9 equ $ - msg9


; [SECTION .text]
;   global main
; main:
;   push  rbp
;   mov   rbp, rsp
;   mov   rax, rdi    ; 第一引数(argc)
;   mov   rbx, rsi    ; 第二引数(argv[0])
;   add   rbx, 0x8    ; 第二引数(argv[1])
;   mov   rax, 60
;   mov   rdi, 0D42
;   syscall
;   mov   rsp, rbp
;   pop   rbp

; [SECTION .text]
;   global main
; main:
;   push  rbp
;   mov   rbp, rsp
;   ; sub   rsp, 0x10

;   mov   rax, rdi    ; 第一引数(argc)
;   mov   rbx, rsi    ; 第二引数(argv[0])
;   add   rbx, 0x8    ; 第二引数(argv[1])
;   push  qword [rbx]

;   mov   rcx, 0x0
;   mov   rax, qword [rbp-8]

; .loop:
;   cmp   byte [rax], 0x0
;   je    .done
;   inc   rax
;   inc   rcx         ; インクリメント
;   jmp   .loop

; .done:
;   mov   rax, 0x1
;   mov   rdi, 0x1    ; fd
;   mov   rsi, [rbp-8]; *buf
;   mov   rdx, rcx    ; count
;   syscall           ; write(fd, *buf, count)

;   mov   rsp, rbp
;   pop   rbp
