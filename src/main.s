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

  ; 1文字入力した文字を取得
  mov rax, qword[rbp-8]
  mov bl, byte [rax]

  cmp bl, 0x30
  je .strtoint_0
  cmp bl, 0x31
  je .strtoint_1
  cmp bl, 0x32
  je .strtoint_2
  cmp bl, 0x33
  je .strtoint_3
  cmp bl, 0x34
  je .strtoint_4
  cmp bl, 0x35
  je .strtoint_5
  cmp bl, 0x36
  je .strtoint_6
  cmp bl, 0x37
  je .strtoint_7
  cmp bl, 0x38
  je .strtoint_8
  cmp bl, 0x39
  je .strtoint_9

.strtoint_0:
  mov rbx, 0
  jmp .strtoint_E
.strtoint_1:
  mov rbx, 1
  jmp .strtoint_E
.strtoint_2:
  mov rbx, 2
  jmp .strtoint_E
.strtoint_3:
  mov rbx, 3
  jmp .strtoint_E
.strtoint_4:
  mov rbx, 4
  jmp .strtoint_E
.strtoint_5:
  mov rbx, 5
  jmp .strtoint_E
.strtoint_6:
  mov rbx, 6
  jmp .strtoint_E
.strtoint_7:
  mov rbx, 7
  jmp .strtoint_E
.strtoint_8:
  mov rbx, 8
  jmp .strtoint_E
.strtoint_9:
  mov rbx, 9
  jmp .strtoint_E

.strtoint_E:


  ; アセンブリコード生成
  print msg1
  print msg2
  print msg3
  print msg4
  print msg5
  print qword[rbp-8]
  print msg6

  mov rsp, rbp
  pop rbp

  mov rax, 60 ;exit syscall 識別子
  mov rdi, 0  ;引数1:終了ステータス
  syscall

[SECTION .data]
msg1 db       '[SECTION .text]', 0xa, 0x0  ; 「0xa」は\n
msg2 db 0x09,   'global _start', 0xa, 0x0
msg3 db         '_start:', 0xa,       0x0
msg4 db 0x09,   'mov rax, 0x3c', 0xa, 0x0 ;exit syscall 識別子
msg5 db 0x09,   'mov rdi, ',          0x0 ;引数1
; 入力された文字列埋め込み
msg6 db 0xa, 0x09, 'syscall', 0xa, 0x0 ;exit呼び出し

; TDD手法 入力した値をexitの終了ステータスとして入れたい
; [SECTION .text]
; 	global _start
; _start:
; 	mov rax, 0x3c ;exit
; 	mov rdi, 			;終了ステータスに入力した値を入れたい
; 	syscall
