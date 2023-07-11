%include "define/ASCIICode.s"

%define True        1
%define False       0

; Token_t
; +----------------+
; | Token Kind     |1byte
; | padding        |3byte
; |                |
; |                |
; | valuse         |4byte
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
; Token Kind
%define TK_EOF      0
%define TK_SIGN     1
%define TK_NUM      2

; Node_t
; +----------------+
; | Node Kind      |4byte
; |                |
; |                |
; |                |
; | int valuse     |4byte
; |                |
; |                |
; |                |
; +----------------+
; | Node_t* Left   |8byte
; |                |
; |                |
; |                |
; |                |
; |                |
; |                |
; |                |
; +----------------+
; | Node_t* Right  |8byte
; |                |
; |                |
; |                |
; |                |
; |                |
; |                |
; |                |
; +----------------+

; Node Kind
%define NK_ADD      1 ;ASCII_PLUS      +
%define NK_SUB      2 ;ASCII_MINUS     -
%define NK_MUL      3 ;ASCII_ASTERISK  *
%define NK_DIV      4 ;ASCII_SLASH     /
%define NK_NUM      5

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

; int(RAX) strtoint(char* strat_point(RDI))
strtoint:
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

; int expect_number(void)
expect_number:
  mov   rbx, [now_token]
  cmp   byte [rbx], TK_NUM
  jnz   .notnumber
  mov   rax, 0
  mov   eax, [rbx+0x4]
  add   rbx, 0x10
  mov   [now_token], rbx
  ret

  .notnumber:
    mov   rdi, errormsg2
    mov   rax, 0
    call  printf
    jmp   exit

; bool expect_sign(char sign)
expect_sign:
  mov   rbx, [now_token]
  cmp   byte[rbx], TK_SIGN
  jnz   .not_expect_sign
  
  mov   rdx, qword[rbx+8]
  mov   al, byte[rdx]
  mov   rcx, rdi
  cmp   al, cl
  jnz   .not_expect_sign

  add   rbx, 0x10
  mov   [now_token], rbx
  mov   rax, True
  ret

  .not_expect_sign:
    mov   rax, False
    ret

; トークナイズ関数
; void tokenize(char *inputString, char *tokenBuf)
tokenize:
  push  rbp
  push  rbx
  push  r12
  push  r13
  mov   rbp, rsp
  sub   rsp, 0x10

  mov   r13, rdi
  mov   r12, rsi
  .tokenize_loop:
    mov   al, byte[r13]
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
    inc   r13
    jmp   .tokenize_loop

  .tokenize_sign:
    ; 一文字分のヒープ領域確保
    mov   rdi, 0x2
    call  new_heap_memory
    mov   dl, byte [r13]
    inc   r13
    mov   [rax], byte dl
    mov   [rax+1], byte 0x0

    ; トーク列追加
    mov   [r12], byte TK_SIGN
    mov   [r12+0x8], rax
    add   r12, 0x10

    jmp   .tokenize_loop

  .tokenize_number:
    mov   rdi, r13
    call  strtoint
    mov   rbx, rax
    mov   r13, rdi

    mov   [r12], byte TK_NUM
    mov   [r12+0x4], ebx
    mov   [r12+0x8], rax
    add   r12, 0x10

    jmp   .tokenize_loop

  .tokenize_error:
    mov   rdi, errormsg1
    mov   rax, 0
    call  printf
    jmp   exit

  .tokenize_done:
    mov   rsp, rbp
    pop   r12
    pop   r13
    pop   rbx
    pop   rbp
    ret

; *node_t func(int kind, int val, node_t *LeftNode, node_t *rightNode)
new_node:
  push  rbp
  mov   rbp, rsp
  sub   rsp, 0x20

  mov   [rbp-0x4], edi
  mov   [rbp-0x8], esi
  mov   [rbp-0x10], rdx
  mov   [rbp-0x18], rcx
  
  mov   rdi, 0x18
  call  new_heap_memory
  
  mov   edi, [rbp-0x4]
  mov   [rax+0x0], edi
  mov   edi, [rbp-0x8]
  mov   [rax+0x4], edi
  mov   rdi, [rbp-0x10]
  mov   [rax+0x8], rdi
  mov   rdi, [rbp-0x18]
  mov   [rax+0x10], rdi
  
  mov   rsp, rbp
  pop   rbp
  ret

; expr = num ("+" num | "-" num)*
; node_t* expr(void)
expr:
  push  rbp
  mov   rbp, rsp
  sub   rsp, 0x10
  
  call  num
  mov   [rbp-0x8], rax

  .expr_loop:
    ; if + かどうか
    mov   rdi, ASCII_PLUS
    call  expect_sign     ;error Pointe new tokenを進めすぎている
    cmp   rax, True
    jz    .add_if

    ; if - かどうか
    mov   rdi, ASCII_MINUS
    call  expect_sign
    cmp   rax, True
    jz    .sub_if

    ; else
    jmp   .expr_done

  .add_if:
    call  num
    mov   [rbp-0x10], rax

    mov   rdi, NK_ADD
    mov   rsi, 0
    mov   rdx, [rbp-0x8]
    mov   rcx, [rbp-0x10]
    call  new_node
    mov   [rbp-0x8], rax
    jmp   .expr_loop

  .sub_if:
    call  num
    mov   [rbp-0x10], rax

    mov   rdi, NK_SUB
    mov   rsi, 0
    mov   rdx, [rbp-0x8]
    mov   rcx, [rbp-0x10]
    call  new_node
    mov   [rbp-0x8], rax
    jmp   .expr_loop

  .expr_done:
    mov   rax, [rbp-0x8]
    mov   rsp, rbp
    pop   rbp
    ret

; num = ( 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 )*
; node_t* num(void)
num:
  call  expect_number
  mov   rdi, NK_NUM
  mov   esi, eax
  mov   rdx, 0x0
  mov   rcx, 0x0
  call  new_node
  ret

; void gen(node_t *node)
gen:
  push  rbp
  push  r12
  mov   rbp, rsp
  sub   rsp, 0x8

  mov   r12, rdi

  ; nodeが葉かどうか
  cmp   dword [r12+0x0], NK_NUM
  jz    .leaf_node

  ; 再帰的に呼び出す
  ; nodeの左を探索
  mov   rdi, qword [r12+0x8]
  call  gen
  ; nodeの右を探索
  mov   rdi, qword [r12+0x10]
  call  gen
  ; 戻ってくる
  
  mov   rdi, msg2
  mov   rax, 0
  call  printf
  mov   rdi, msg3
  mov   rax, 0
  call  printf

  mov   r8d, dword [r12+0x0]
  cmp   r8d, NK_ADD
  jz    .add_node
  cmp   r8d, NK_SUB
  jz    .sub_node
  cmp   r8d, NK_MUL
  jz    .mul_node
  cmp   r8d, NK_DIV
  jz    .div_node

  .leaf_node:
    mov   rdi, msg1
    mov   esi, dword [r12+0x4]
    mov   rax, 0
    call  printf
    jmp   .gen_done

  .add_node:
    mov   rdi, msg4
    mov   rax, 0
    call  printf
    jmp   .break
  .sub_node:
    mov   rdi, msg5
    mov   rax, 0
    call  printf
    jmp   .break
  .mul_node:
    mov   rdi, msg6
    mov   rax, 0
    call  printf
    jmp   .break
  .div_node:
    mov   rdi, msg7
    mov   rax, 0
    call  printf
    mov   rdi, msg8
    mov   rax, 0
    call  printf
    jmp   .break

  .break:
    mov   rdi, msg9
    mov   rax, 0
    call  printf
    jmp   .gen_done

  .gen_done:
    mov   rdi, 0
    call  fflush
    mov   rsp, rbp
    pop   r12
    pop   rbp
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

  ; トークナイズ
; void tokenize(char *inputString, char *tokenBuf)
  mov   rdi, [rbp-8]
  mov   rsi, charspace
  call  tokenize

  ; アセンブリコード前半出力
  mov   rdi, msg_start1
  mov   rax, 0
  call  printf
  mov   rdi, msg_start2
  mov   rax, 0
  call  printf
  mov   rdi, msg_start3
  mov   rax, 0
  call  printf

; パーサ(抽象構文木生成)
  mov   rax, charspace
  mov   [now_token], rax
  call  expr

  ; コード生成
  mov   rdi, rax
  call  gen

  ; アセンブリコード後半出力
  mov   rdi, msg10
  call  printf
  mov   rdi, msg_end1
  mov   rax, 0
  call  printf
  mov   rdi, msg_end2
  mov   rax, 0
  call  printf
  mov   rdi, msg_end3
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
msg_start1  db       '[SECTION .text]',   0xa, 0x0
msg_start2  db 0x09,   'global _start',   0xa, 0x0
msg_start3  db       '_start:',           0xa, 0x0
msg1        db 0x09,   'push %d',         0xa, 0x0
msg2        db 0x09,   'pop rdi',         0xa, 0x0
msg3        db 0x09,   'pop rax',         0xa, 0x0
msg4        db 0x09,   'add rax, rdi',    0xa, 0x0
msg5        db 0x09,   'sub rax, rdi',    0xa, 0x0
msg6        db 0x09,   'imul rax, rdi',   0xa, 0x0
msg7        db 0x09,   'cqo',             0xa, 0x0
msg8        db 0x09,   'idiv rdi',        0xa, 0x0
msg9        db 0x09,   'push rax',        0xa, 0x0
msg10       db 0x09,   'pop rax',         0xa, 0x0

msg_end1    db 0x09,   'mov rdi, rax',    0xa, 0x0 ;引数1
msg_end2    db 0x09,   'mov rax, 0x3c',   0xa, 0x0 ;exit syscall 識別子
msg_end3    db 0x09, 'syscall',           0xa, 0x0 ;exit呼び出し

errormsg1 db "Failed: Didn't tokenize",  0xa, 0x0
errormsg2 db "Failed: This token isn't number",  0xa, 0x0
errormsg3 db "Failed: Syntax error",  0xa, 0x0

charspace times 200 db 0x0
; global
now_token dq qword 0x0

; expr = num ("+" num | "-" num)*
; num  = ( 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 )*

; TDD手法2 構文木を生成し加減算を解く ex)2+3+4+5
; [SECTION .text]
; 	global _start
; _start:
;   // 2*3を計算
  ; push 2
  ; push 3
  ; pop rdi
  ; pop rax
  ; add rax, rdi
  ; push rax

  ; // 4*5を計算
  ; push 4
  ; push 5
  ; pop rdi
  ; pop rax
  ; add rax, rdi
  ; push rax

  ; pop rdi
  ; pop rax
  ; add rax, rdi
  ; push rax
	; mov rdi, rax	;終了ステータスに入力した値を入れたい
  ; mov rax, 0x3c
	; syscall