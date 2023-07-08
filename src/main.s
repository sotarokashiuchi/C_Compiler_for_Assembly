%include "define/ASCIICode.s"

; Token Kind
%define TK_EOF      0
%define TK_RESERVED 1
%define TK_NUM      2

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
; int(RAX) num(char* strat_point(RDI))
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

; ヒープ領域の確保
; void* new_heap_memory(size)
new_heap_memory:
  mov   rsi, rdi
  
  ; 現在のbreak位置確認
  mov   rax, 0x0c   ; brk
  mov   rdi, 0
  syscall
  mov   rdx, rax

  ; break位置拡張
  mov   rdi, rax
  mov   rax, 0xc
  add   rdi, rsi
  syscall

  mov   rax, rdx
  ret

; 関数呼び出し規約(整数) RAX funx1(RDI, RSI, RDX, RCX, R8, R9, スタック, スタック, スタック, スタック)
; syscall呼び出し規約 RAX RAX(RDI, RSI, RDX, r10, r8, r9)

[SECTION .text]
  extern printf
  extern fflush
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


  mov   rdi, 0xc
  call new_heap_memory
  mov   rsi, rax

  ; 確保したヒープ領域に文字列を書き込み
  mov   [rsi+0], byte ASCII_H
  mov   [rsi+1], byte ASCII_e
  mov   [rsi+2], byte ASCII_l
  mov   [rsi+3], byte ASCII_l
  mov   [rsi+4], byte ASCII_o
  mov   [rsi+5], byte ASCII_W
  mov   [rsi+6], byte ASCII_o
  mov   [rsi+7], byte ASCII_r
  mov   [rsi+8], byte ASCII_l
  mov   [rsi+9], byte ASCII_d
  mov   [rsi+10], byte 0xa
  mov   [rsi+11], byte 0x0
  print rsi

  ; アセンブリコード前半出力
  mov   rdi, msg1
  mov   rax, 0
  call  printf
  mov   rdi, msg2
  mov   rax, 0
  call  printf
  mov   rdi, msg3
  mov   rax, 0
  call  printf

  ; 1つ目の項を取得
  mov   rdi, qword[rbp-8]
  call  num
  mov   qword[rbp-8], rdi
  mov   rdi, msg4
  mov   rsi, rax
  mov   rax, 0
  call  printf

.main_loop:
  mov   rdi, qword[rbp-8]
  cmp   byte[rdi], 0x0
  je    .main_done
  
  ; if + かどうか
  cmp   byte[rdi], ASCII_PLUS
  je    .add_if

  ; if - かどうか
  cmp   byte[rdi], ASCII_MINUS
  je    .sub_if

.add_if:
  inc   rdi
  call  num
  mov   qword[rbp-8], rdi
  mov   rdi, msg5
  mov   rsi, rax
  mov   rax, 0
  call  printf
  jmp   .main_loop

.sub_if:
  inc   rdi
  call  num
  mov   qword[rbp-8], rdi
  mov   rdi, msg6
  mov   rsi, rax
  mov   rax, 0
  call  printf
  jmp   .main_loop

.main_done:
  ; アセンブリコード後半出力
  mov   rdi, msg7
  mov   rax, 0
  call  printf
  mov   rdi, msg8
  mov   rax, 0
  call  printf
  mov   rdi, msg9
  mov   rax, 0
  call  printf

  mov   rdi, 0
  call  fflush

  mov rsp, rbp
  pop rbp

  mov rax, 60 ;exit syscall 識別子
  mov rdi, 0  ;引数1:終了ステータス
  syscall

[SECTION .data]
msg1 db       '[SECTION .text]',  0xa, 0x0
msg2 db 0x09,   'global _start',  0xa, 0x0
msg3 db       '_start:',          0xa, 0x0
msg4 db 0x09,   'mov rax, %d',  0xa, 0x0
msg5 db 0x09,   'add rax, %d',  0xa, 0x0 ;exit syscall 識別子
msg6 db 0x09,   'sub rax, %d',  0xa, 0x0 ;exit syscall 識別子

msg7 db 0x09,   'mov rdi, rax',    0xa, 0x0 ;引数1
msg8 db 0x09,   'mov rax, 0x3c',  0xa, 0x0 ;exit syscall 識別子
msg9 db 0x09, 'syscall',          0xa, 0x0 ;exit呼び出し
msg10 db 0xa, 'a', 0x0

charspace times 200 db 0x0

; TDD手法1 brkシステムコールを用いて、ヒープ領域を確保し、文字列を格納し、表示させるプログラムの作成
  ; Hello Wold

; TDD手法2 空白が含まれていても、加減算を行えるプログラムの作成
; [SECTION .text]
; 	global _start
; _start:
;   mov rax, 5
;   add rax, 20
;   sub rax, 5
;   add rax, 3
; 	mov rdi, rax	;終了ステータスに入力した値を入れたい
;   mov rax, 0x3c
; 	syscall