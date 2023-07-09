%include "define/ASCIICode.s"

%define True        1
%define False       0

; Token Kind
%define TK_EOF      0
%define TK_SIGN     1
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

; int expect_number(Token_t *token)
expect_number:
  mov   rax, 0
  cmp   byte [rdi], TK_NUM
  jnz   .notnumber
  mov   rdx, qword[rdi+8]
  mov   eax, dword[rdx]
  add   rdi, 0x10
  ret

.notnumber:
  mov   rdi, errormsg2
  mov   rax, 0
  call  printf
  jmp   exit

; bool expect_sign(Token_t *token, char sign)
expect_sign:
  cmp   byte[rdi], TK_SIGN
  jnz   .not_expect_sign
  
  mov   rdx, qword[rdi+8]
  mov   al, byte[rdx]
  mov   rcx, rsi
  cmp   al, cl
  jnz   .not_expect_sign

  add   rdi, 0x10
  mov   rax, True
  ret

.not_expect_sign:
  mov   rax, False
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

  ; +----------------+
  ; | Token Kind     |1byte
  ; | padding        |7byte
  ; |                |
  ; |                |
  ; |                |
  ; |                |
  ; |                |
  ; |                |
  ; +----------------+
  ; | pointer        |8byte
  ; |                |
  ; |                |
  ; |                |
  ; |                |
  ; |                |
  ; |                |
  ; |                |
  ; +----------------+
  ; トークナイズ
  mov   r8, charspace
  mov   r9, qword[rbp-8]
.tokenize_loop:
  mov   al, byte[r9]
  ; トークナイズ終了条件
  cmp   al, ASCII_NULL
  je    .tokenize_done

  ; トークンが空白
  cmp   al, ASCII_SPACE
  jz    .tokenize_space

  ; トークンが記号の場合
  cmp   al, ASCII_PLUS
  jz    .tokenize_sign
  cmp   al, ASCII_MINUS
  jz    .tokenize_sign

  ; トークンが数字の場合
  cmp   al, ASCII_0
  jz    .tokenize_number
  cmp   al, ASCII_1
  jz    .tokenize_number
  cmp   al, ASCII_2
  jz    .tokenize_number
  cmp   al, ASCII_3
  jz    .tokenize_number
  cmp   al, ASCII_4
  jz    .tokenize_number
  cmp   al, ASCII_5
  jz    .tokenize_number
  cmp   al, ASCII_6
  jz    .tokenize_number
  cmp   al, ASCII_7
  jz    .tokenize_number
  cmp   al, ASCII_8
  jz    .tokenize_number
  cmp   al, ASCII_9
  jz    .tokenize_number

  jmp   .tokenize_error

.tokenize_space:
  inc   r9
  jmp   .tokenize_loop

.tokenize_sign:
  ; 一文字分のヒープ領域確保
  mov   rdi, 0x2
  call  new_heap_memory
  mov   dl, byte [r9]
  inc   r9
  mov   [rax], byte dl
  mov   [rax+1], byte 0x0

  ; トーク列追加
  mov   [r8], byte TK_SIGN
  mov   [r8+0x8], rax
  add   r8, 0x10

  jmp   .tokenize_loop

.tokenize_number:
  mov   rdi, r9
  call  num
  mov   rbx, rax
  mov   r9, rdi

  ; int分(4byte)のヒープ領域確保
  mov   rdi, 0x4
  call  new_heap_memory
  mov   [rax], ebx

  mov   [r8], byte TK_NUM
  mov   [r8+0x8], rax
  add   r8, 0x10

  jmp   .tokenize_loop

.tokenize_error:
  mov   rdi, errormsg1
  mov   rax, 0
  call  printf
  jmp   exit

.tokenize_done:

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

  mov   r12, charspace
  ; 1つ目の項を取得
  mov   rdi, r12
  call  expect_number
  mov   r12, rdi
  mov   rdi, msg4
  mov   rsi, rax
  mov   rax, 0
  call  printf

.main_loop:
  mov   rdi, r12
  cmp   byte[rdi], TK_EOF
  jz    .main_done
  
  ; if + かどうか
  mov   rsi, ASCII_PLUS
  call  expect_sign
  cmp   rax, True
  jz    .add_if

  ; if - かどうか
  mov   rsi, ASCII_MINUS
  call  expect_sign
  cmp   rax, True
  jz    .sub_if

  jmp   .main_error

.add_if:
  call  expect_number
  mov   r12, rdi
  mov   rdi, msg5
  mov   rsi, rax
  mov   rax, 0
  call  printf
  jmp   .main_loop

.sub_if:
  call  expect_number
  mov   r12, rdi
  mov   rdi, msg6
  mov   rsi, rax
  mov   rax, 0
  call  printf
  jmp   .main_loop

.main_error:
  mov   rdi, errormsg3
  mov   rax, 0
  call  printf
  jmp   exit

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

exit:
  mov   rdi, 0
  call  fflush
  mov rax, 60 ;exit syscall 識別子
  mov rdi, 0  ;引数1:終了ステータス
  syscall

  mov rsp, rbp
  pop rbp

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

errormsg1 db "Failed: Didn't tokenize",  0xa, 0x0
errormsg2 db "Failed: This token isn't number",  0xa, 0x0
errormsg3 db "Failed: Syntax error",  0xa, 0x0

charspace times 200 db 0x0

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