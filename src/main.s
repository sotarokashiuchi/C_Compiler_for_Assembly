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
  mov   r8, qword[rbx]
  mov   [rbp-8], r8
  ; push  qword [rbx]

  ; 十進数の文字列から二進数の数値に変換
  mov   r8, qword[rbp-8]
  mov   rcx, 0x0
  mov   rax, 0x0
  mov   rbx, 0x0

.strtoint_loop:
  cmp   byte [r8], 0x0
  je    .strtoint_done
  mov   bl, byte [r8]
  and   bl, 0B0000_1111   ; 文字を数値に変換
  inc   r8                ; r8++
  inc   rcx               ; rcx++
  ; rbxレジスタを桁数に合わせて乗算する
  imul  rax, dword 0B1010
  add   rax, rbx
  jmp   .strtoint_loop
.strtoint_done:

  ; 入力数値をインクリメント
  inc   rax

  ; 二進数の数値を十進数の文字列に変換
  mov   rcx, msgchar1
  add   rcx, 0x8
  mov   [rcx], byte 0x00
  mov   r8,  qword 0B1010
.inttostr_loop:
  cmp   rax, 0x0
  je    .inttostr_done
  mov   rdx, 0x0          ; 乗算の結果(剰余)を格納するレジスタを初期化(idiv前に必ず初期化する必要あり?)
  idiv  r8                ; RAX/0x1010 = RAX余りRDX (余りが十進数の下の桁になる)
  or    rdx, 0B0011_0000  ; 数値を文字に変換
  dec   rcx               ; rcx--
  mov   [rcx], dl         ; 文字列になるように格納
  jmp   .inttostr_loop
.inttostr_done:

  ; アセンブリコード生成
  print msg1
  print msg2
  print msg3
  print msg4
  print msg5
  print msgchar1
  print msg6

  mov rsp, rbp
  pop rbp

  mov rax, 60 ;exit syscall 識別子
  mov rdi, 0  ;引数1:終了ステータス
  syscall

[SECTION .data]
msg1 db       '[SECTION .text]', 0xa, 0x0
msg2 db 0x09,   'global _start', 0xa, 0x0
msg3 db         '_start:', 0xa,       0x0
msg4 db 0x09,   'mov rax, 0x3c', 0xa, 0x0 ;exit syscall 識別子
msg5 db 0x09,   'mov rdi, ',          0x0 ;引数1
; 入力された文字列を数値に変換し、インクリメントした値を再び文字列に戻し出力
msg6 db 0xa, 0x09, 'syscall', 0xa, 0x0 ;exit呼び出し
msgchar1 db '        '

; TDD手法 複数桁の入力した値に1を足した値をexitの終了ステータスとして入れたい
; [SECTION .text]
; 	global _start
; _start:
; 	mov rax, 0x3c ;exit
; 	mov rdi, 			;終了ステータスに入力した値を入れたい
; 	syscall
