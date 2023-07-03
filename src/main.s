; rcxとraxの退避が必要
%macro print 1
  mov   rax, %1
  mov   rcx, 0x0

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

; num = ( 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 )*
; int(RAX) num(char* strar_point(RDI))
num:
  ; 初期設定
  push  rbp
  mov   rbp, rsp
  push  rbx

  mov   rax, 0x0
  mov   rbx, 0x0
  mov   rdx, 0x0

.strtoint_loop:
  ; 上位4bitが 0B0011 かどうか
  mov   al, byte[rdi]
  and   al, 0B1111_0000
  cmp   al, 0B0011_0000
  jnz   .strtoint_done ; ZF==0

  ; 下位4bitが 0B1001 以下かどうか
  mov   al, byte[rdi]
  and   al, 0B0000_1111
  mov   bl, 0B0000_1010
  div   bl
  cmp   al, 0x0
  jnz   .strtoint_done ; ZF==0

  mov   rax, 0x0
  mov   al, byte [rdi]
  and   al, 0B0000_1111   ; 文字を数値に変換
  inc   rdi               ; rdi++
  ; rbxレジスタを桁数に合わせて乗算する
  imul  rdx, dword 0B1010
  add   rdx, rax
  jmp   .strtoint_loop

.strtoint_done:
  ; 終期設定
  mov   rax, rdx
  pop   rbx
  mov   rsp, rbp
  pop   rbp
  ret

; 関数呼び出し規約(整数) RAX funx1(RDI, RSI, RDX, RCX, R8, R9, スタック, スタック, スタック, スタック)
; syscall呼び出し規約 RAX RAX(RDI, RSI, RDX, r10, r8, r9)

[SECTION .text]
  extern printf
  extern fprintf
  global main       ;エントリーポイント
	
main:
  push  rbp
  mov   rbp, rsp
  sub   rsp, 0x10

  mov   rax, rdi    ; 第一引数(argc)
  mov   rbx, rsi    ; 第二引数(argv[0])
  add   rbx, 0x8    ; 第二引数(argv[1])
  mov   r8, qword[rbx]
  mov   [rbp-8], r8

  ; テスト実行
  mov   rdi, qword[rbp-8]
  call  num

  ; 入力数値をインクリメント
  inc   rax
  mov   qword[rbp-16], rax


  ; mov   rdi, 4
  ; mov   rsi, msg1
  ; mov   rax, 0
  ; call  fprintf

  ; アセンブリコード生成
  mov   rdi, msg1
  mov   rax, 0
  call  printf
  mov   rdi, msg2
  mov   rax, 0
  call  printf
  mov   rdi, msg3
  mov   rax, 0
  call  printf
  mov   rdi, msg4
  mov   rax, 0
  call  printf
  mov   rdi, msg5
  mov   rsi, qword[rbp-16]
  mov   rax, 0
  call  printf
  mov   rdi, msg6
  mov   rax, 0
  call  printf

  mov rsp, rbp
  pop rbp

  mov rax, 60 ;exit syscall 識別子
  mov rdi, 0  ;引数1:終了ステータス
  syscall

[SECTION .data]
msg1 db       '[SECTION .text]',  0xa, 0x0
msg2 db 0x09,   'global _start',  0xa, 0x0
msg3 db       '_start:',          0xa, 0x0
msg4 db 0x09,   'mov rax, 0x3c',  0xa, 0x0 ;exit syscall 識別子
msg5 db 0x09,   'mov rdi, %d',    0xa, 0x0 ;引数1
msg6 db 0x09, 'syscall',          0xa, 0x0 ;exit呼び出し

; TDD手法 複数桁の入力した値に1を足した値をexitの終了ステータスとして入れたい
; [SECTION .text]
; 	global _start
; _start:
; 	mov rax, 0x3c ;exit
; 	mov rdi, 			;終了ステータスに入力した値を入れたい
; 	syscall
