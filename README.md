## 目的と縛り
- アセンブリ言語でCコンパイラを作成すること
  - libcのprintf関数, fflush関数のみ呼び出して良いことにする
  - それ以外のlibcは使わない(予定)
- 目的を達成する前段階として、C言語でCコンパイラを作成中
  - [C_Compiler_for_CのGitHub](https://github.com/sotarokashiuchi/C_Compiler_for_C.git)

## 開発環境
| ツール名   | ツール バージョン                            |
| ---------- | -------------------------------------------- |
| OS         | Ubuntu 22.04.2 LTS                           |
| アセンブラ | NASM version 2.16.01 compiled on Jun 18 2023 |
| リンカ     | GNU ld (GNU Binutils for Ubuntu) 2.38        |
|            | cc (Ubuntu 11.3.0-1ubuntu1~22.04.1) 11.3.0   |

```shell
# 自作Cコンパイラ作成
make

# テストを実行
make test

# tmpファイル削除
make clean

# コマンドを用いて自作コンパイラのビルドとコンパイラの実行
nasm -f elf64 -g -o main.o -l main.lts main.s
cc -static -o ccompiler main.o
./compiler <option> > tmp.s
nasm -f elf64 -g -o tmp.o -l tmp.lts tmp.s
ld -m elf_x86_64 -o tmp tmp.o
./tmp
```

## 計画
- [x] (2023/06/18)環境の構築
  - [x] (2023/06/17):WSL2のインストール
  - [x] (2023/06/17)VSCodeとWSL2との連携方法を知る
    - 参考資料:[Microsoft](https://learn.microsoft.com/ja-jp/windows/wsl/about)
  - [x] (2023/06/17)GitとWSL2の連帯方法を知る
    - GitHubにバックアップを取っているため、別Driveに分ける必要がない。
    - GitをWindows、WSLともにインストールし、GitHubアカウントを共有することができる
      - [WSLでGitの使用を開始する](https://learn.microsoft.com/ja-jp/windows/wsl/tutorials/wsl-git)
      - Git Credential Manager(GCM)のpathがホストのGitのバージョンによって異なるので注意
    - ~~Program専用DriveをWindows側、WSL2側で共有してgitコマンドで管理する。~~
    - ~~WSL2側のgitを削除し、WSL側のターミナルからはWindows側のgit(git.exe)を実行することで、同じアカウントでWindows、WSLともに利用できる~~
    - ~~問題点:VSCodeのGitのサポートを受けれない(Editerの行番号に変更箇所の色が付かないなど)(保留)~~
  - [x] (2023/06/17)Discordの音声が認識されない不具合を修正
  - [x] (2023/06/18)NASMのインストール
    - 「NASM_Tutorial:03:Environment Setup」
  - [ ] (保留)VimでESCを入力した時のIME制御プログラムのバグを修正
    - 原因不明の為保留する
- [x] (2023/06/18)アセンブラの使い方を学ぶ
  - [x] (2023/06/18)「書籍1:09:アセンブラ(NASM)の使い方」
  - [x] (2023/06/18)「書籍1:12:開発環境を構築する」
- [x] (2023/06/18)実行可能ファイルの作り方を学ぶ
  - [x] (2023/06/18)nasmのオプションを知る
  - [x] (2023/06/18)ldのオプションを知る
  - [x] (2023/06/18)「NASM_Tutorial:04:Basic Syntax」
- [x] (2023/06/25)アセンブリ言語の基本を知る
  - [x] (2023/06/18)「書籍1:06:コンピュータの基本構成」
  - [x] (2023/06/19)「書籍1:07:CPUの基本機能」
  - [x] (2023/06/22)「書籍1:08:CPU命令の使い方」
  - [x] (2023/06/18)「書籍1:09:アセンブラ(NASM)の使い方」
  - [x] (2023/06/25)「書籍1:13:アセンブラによる制御構文と関数の記述例」
- [x] プログラムレビューをしやすいようにマニュアルを作成(<---Now:2023/06/24)
- [x] (2023/06/26)「compilerbook:1:整数1個をコンパイルする言語の作成」
  - [x] (2023/06/21)出力:結果をシステムコールを通じて表示
  - [x] (2023/06/24)システムコールの理解を深める
    - [SystemV ABI AMD64](https://refspecs.linuxfoundation.org/elf/x86_64-abi-0.99.pdf)のP124「A.2 AMD64 Linux Kernel Conventions」にAMD64の場合の規約がある
    - 関数呼び出し規約と少し違う点に注意
  - [x] (2023/06/24)入力:データを取り込む
    - ldコマンドとccコマンドの関係と違い
      - ccコマンドはldコマンドを内部的に呼び出している
      - ldコマンドはデフォルトで`__start`シンボルをエントリーポイントとしている。またスタートアップルーチンなどを付け加えることがない。そのため、スタートアップルーチンを含む処理をアセンブリ言語で書く必要がある。OSなどを作成する時には有用。
      - ccコマンドはスタートアップルーチンがmainを呼び出すようにリンクする。mainを関数として呼び出すため、mainでretを行うことができる。またスタートアップルーチンがコマンドラインから引数を受け取り、mainの第一引数、第二引数に渡している。
  - [x] (2023/06/25)test.shの導入
  - [x] (2023/06/25)Makefileの作成
  - [x] (2023/06/25)gitの設定
  - [x] (2023/06/26)入力データを出力
    - 複数桁の数値の入力に対応
    - 文字を格納するためのメモリ領域をどのように確保するかが課題
- [x] (2023/07/05)「compilerbook:2:加減算の実現」 (<---Now:2023/06/25)
  - [x] (2023/07/03)printf(libc)の呼び出し
    - [参考](https://www.mourtada.se/calling-printf-from-the-c-standard-library-in-assembly/)
  - [x] (2023/07/05)「+」記号と「-」記号の認識
  - [x] (2023/07/05)加減算の実現
  - [x] バグ:出力をリダイレクトしてtmp.sファイルに書き込むことができない
    - printfで出力させており、printfのバッファに溜まっている文字列が出力されていなかった
    - printfは改行でフラッシュされるわけではないみたい
    - fflush関数を使用して解決
- [ ] VSCode live share環境構築
- [x] (2023/07/08)gdbデバッガー拡張
  - [x] (2023/07/08)[GDB dashboard](https://github.com/cyrus-and/gdb-dashboard)
    - GDB dashboardとはGDBデバッガーの複雑なコマンドを簡潔なコマンドにまとめたり、便利な機能をデフォルトでセットしてくれる
    - デバッグ情報があるバイナリに使用する
  - [x] (2023/07/08)[GDB peda](https://github.com/longld/peda)
    - GDB pedaはとはGDBデバッガーの複雑なコマンドを簡潔なコマンドにまとめたり、便利な機能をデフォルトでセットしてくれる
    - デバッグ情報がないバイナリに使用する
  - dashboardとpedaの使い分けと設定方法
    - 「dashboard」と「peda」と「自作.gdbinit」はどちらも.gdbinitを使用するので競合する
    - そのため「dashboard」と「peda」が別のコマンドで起動するようにする
      - `alias peda='gdb -nx -ix=~/.gdbinit_peda'`をbashrcなどに記述する
      - dashboardが「gdbコマンド」で起動
      - pedaが「pedaコマンド」で起動
    - 自作.gdbinitは「dashboard」と「peda」の両方のファイルに記述しておくか`-x`オプションで複数のcommand fileを読み込むようにする
- [x] (2023/07/08)「compilerbook:3：トークナイザを導入」
  - [x] (2023/07/08)ヒープ領域の確保方法を学ぶ(malloc)
    - mallocが内部で呼び出しているrbkシステムコールを使用する
    - ヒープ領域もスタックのように伸び縮みする
    - [メモリ管理について](http://www.coins.tsukuba.ac.jp/~yas/coins/os2-2022/2023-01-11/index.html)
    - [brkシステムについて](https://stackoverflow.com/questions/6988487/what-does-the-brk-system-call-do)
    - [mallocの実装](https://github.com/ushitora-anqou/aqcc/blob/master/as/stdlib.c)
  - [x] (2023/07/11)グローバル変数の定義方法を学ぶ
    - グローバル変数はdataセクションの空間に比較的簡単に作れる
  - [x] (2023/07/08)トークナイズする
- [ ] 「compilerbook:5：四則演算のできる言語の作成」
  - [x] (2023/07/12)アセンブリ言語で再帰関数について学ぶ
  - [x] (2023/07/12)全ての関数をABI規約に合うようにする
    - rbp, rbx, r12~r15レジスタの退避
    - 関数呼び出し時に16byte境界のアライメント制約を守る
  - [x] (2023/07/11)加減算の抽象構文木を作成する
    - 抽象構文木と具象構文木の違い
    - 具象構文木:BNF記法を基にそのまま作成された構文木
    - 抽象構文木:具象構文木を2分木で表し、計算順序を一意に決定した構文木
    - 現時点のプログラムはいきなり抽象構文木を生成する
  - [x] (2023/07/11)加減算の抽象構文木を基にコード生成
  - [x] (2023/07/12)四則演算の抽象構文木を作成する
  - [x] (2023/07/12)四則演算の抽象構文木を基にコード生成
  - [x] (2023/07/12)括弧の抽象構文木を作成する
  - [x] (2023/07/12)括弧の抽象構文木を基にコード生成
- [x] (2023/08/07)アセンブリ言語の仕様の読み方を学ぶ
  - [x] (2023/08/07)SDM(SoftwareDevelopmentManual)の読み方を学ぶ
- [ ] セキュリティ・キャンプ全国大会
  - [x] (2023/08/11)参加！！
  - [x] (2023/08/11)[成果発表資料](sheet/SeccampResultsPresentation.pdf)作成＆発表
  - [ ] 参加記作成
  - [ ] 応募課題晒作成
- [x] (2023/08/21)Gitについて学ぶ
  - [x] (2023/08/17)Gitの基本機能について学ぶ
  - [x] (2023/08/21)Gitが学べる資料を作成
    - [資料](https://github.com/sotarokashiuchi/JointDevelopmentEnviromentLesson)
- [ ] GitHubについて学ぶ
  - [ ] GitHubの基本について学ぶ
  - [ ] GitHub Actionsについて学ぶ
  - [ ] GitHubが学べる資料を作成


## 改善点, 改良点
- [ ] token_t構造体のフォーマットの変更(node_t構造体と同じようにkindメンバのサイズをdwordに変更する)
- [ ] レジスタの値操作をする時にも、byte, dword, qwordなどを書く
- [ ] 即値を表す時の規則を決める
  - 0B, 0x, 0D などを付ける時の規則
  - アドレッシング方式の時に使用する即値の表し方の統一等
- [ ] brk systemCallは古く、mmap systemCallが使われるよう

## 資料
### 書籍1:作って理解するOS x86系コンピュータを動かす理論と実装
- [ ] コンピュータの基礎を理解する
  - [x] 01:(2023/06/15)ハードウェアの基礎
  - [x] 02:(2023/08/06)ソフトウェアの基礎
  - [x] 03:(2023/08/28)メモリ管理のしくみ
  - [x] 04:(2023/08/29)ファイルシステムのしくみ
  - [x] 05:(2023/09/01)入出力のしくみ
- [ ] x86系PCのアーキテクチャを理解する
  - [x] 06:コンピュータの基本構成
  - [x] 07:CPUの基本機能
  - [x] 08:CPU命令の使い方
  - [x] 09:アセンブラ(NASM)の使い方
  - [ ] 10:周辺機器の制御方法
  - [ ] 11:BIOSの役割
- [ ] OSを実装する
  - [x] 12:開発環境を構築する
  - [x] 13:アセンブラによる制御構文と関数の記述例
  - [ ] 14:リアルモードでの基本動作を実装
  - [ ] 15:プロテクトモードへの移行を実現
  - [ ] 16:プロテクトモードでの画面出力を実現する
  - [ ] 17:現在時刻を表示する
  - [ ] 18:プロテクトモードでの割り込みを実現する
  - [ ] 19:マルチタスクを実現する
  - [ ] 20:特権状態を管理
  - [ ] 21:小数演算を行う
  - [ ] 22:ページング機能を利用する
  - [ ] 23:コードを共有する
  - [ ] 24:ファイルシステムを利用する
  - [ ] 25:モード移行を実現する
  - [ ] 26:ファイルの読み出しを実現する
  - [ ] 27:PCの電源を切る

### 書籍2:C言語ポインタ完全制覇
- [x] 第0章:本書の狙いと対象読者―イントロダクション
  - [x] 1:(2023/06/21)本書の狙い
  - [x] 2:(2023/06/21)対象読者と構成
- [x] 第1章:まずは基礎から―予備知識と復習
  - [x] 1:(2023/07/08)Cはどんな言語なのか
  - [x] 2:(2023/07/08)メモリとアドレス
  - [x] 3:(2023/07/11)ポインタについて
  - [x] 4:(2023/07/11)配列について
- [x] 第2章:実験してみよう―Cはメモリをどう使うのか
  - [x] 1:(2023/07/11)仮想アドレス
  - [x] 2:(2023/07/11)Cのメモリの使い方う
  - [x] 3:(2023/07/11)関数と文字列リテラル
  - [x] 4:(2023/07/11)静的変数
  - [x] 5:(2023/07/16)自動変数（スタック）
  - [x] 6:(2023/07/08)malloc( )による動的な領域確保（ヒープ）
  - [x] 7:(2023/07/18)アラインメント
  - [x] 8:(2023/07/18)バイトオーダー
  - [x] 9:(2023/07/18)言語仕様と実装について―ごめんなさい，ここまでの内容はかなりウソです
- [x] 第3章:Cの文法を解き明かす―結局のところ，どういうことなのか？
  - [x] 1:(2023/07/25)Cの宣言を解読する
  - [x] 2:(2023/07/25)Cの型モデル
  - [x] 3:(2023/08/02)式
  - [x] 4:(2023/08/02)続・Cの宣言を解読する
  - [x] 5:(2023/08/02)その他
  - [x] 6:(2023/08/02)頭に叩き込んでおくべきこと―配列とポインタは別物だ!!
- [x] 第4章:定石集―配列とポインタのよくある使い方
  - [x] 1:(2023/07/25)基本的な使い方
  - [x] 2:(2023/08/05)組み合わせて使う
- [x] 第5章:データ構造―ポインタの真の使い方
  - [x] 1:(2023/08/05)ケーススタディ1:単語の使用頻度を数える
  - [x] 2:(2023/08/05)ケーススタディ2:ドローツールのデータ構造
- [x] 第6章:その他―落ち穂拾い
  - [x] 1:(2023/08/05)新しい関数群
  - [x] 2:(2023/08/05)落とし穴
  - [x] 3:(2023/08/05)イディオム

### 書籍3:C言語によるプログラミング[スーパーリファレンス編]
- [x] 1:(2023/10/17)Ｃ言語文法の概要とプログラムの構成
- [x] 2:(2023/10/17)翻訳環境と実行環境
- [x] 3:(2023/10/21)文字
- [x] 4:(2023/10/21)字句
- [x] 6:(2023/10/23)キーワード
- [x] 7:(2023/10/24)定数
- [x] 8:(2023/10/25)文字列リテラル
- [x] 9:(2023/10/26)型
- [x] 10:(2023/11/15)宣言と定義
- [x] 11:(2023/11/17)演算子
- [x] 12:(2023/11/19)式
- [x] 13:(2023/11/20)定数式
- [x] 14:(2023/11/21)初期化
- [x] 15:(2023/11/21)文
- [ ] 20:選択文
- [ ] 21:繰り返し文
- [ ] 22:分岐文
- [ ] 23:注釈
- [ ] 24:配列
- [x] 16:(2023/11/22)札付き文
- [x] 17:(2023/11/23)複合文
- [x] 18:(2023/11/24)式文
- [x] 19:(2023/11/25)空文
- [ ] 25:ポインタ
- [ ] 26:関数
- [ ] 27:構造体・共用体
- [ ] 28:前処理指令

### compilerbook:[低レイヤを知りたい人のためのCコンパイラ作成入門](https://www.sigbus.info/compilerbook) for Assembly
- [x] 1：(2023/06/26)整数1個をコンパイルする言語の作成
- [x] 2：(2023/07/05)加減算のできるコンパイラの作成
- [x] 3：(2023/07/08)トークナイザを導入
- [ ] 4：エラーメッセージを改良
- [x] 5：(2023/07/12)四則演算のできる言語の作成
- [x] 6：(2023/07/12)単項プラスと単項マイナス
- [ ] 7: 比較演算子
- [ ] 8: ファイル分割とMakefileの変更
- [ ] 9：1文字のローカル変数
- [ ] 10：複数文字のローカル変数
- [ ] 11：return文
- [ ] 12: 制御構文を足す
- [ ] 13: ブロック
- [ ] 14: 関数の呼び出しに対応する
- [ ] 15: 関数の定義に対応する
- [ ] 16: 単項&と単項*
- [ ] 17: 暗黙の変数定義を廃止して、intというキーワードを導入する
- [ ] 18: ポインタ型を導入する
- [ ] 19: ポインタの加算と減算を実装する
- [ ] 20: sizeof演算子
- [ ] 21: 配列を実装する
- [ ] 22: 配列の添字を実装する
- [ ] 23: グローバル変数を実装する
- [ ] 24: 文字型を実装する
- [ ] 25: 文字列リテラルを実装する
- [ ] 26: 入力をファイルから読む
- [ ] 27: 行コメントとブロックコメント
- [ ] 28: テストをCで書き直す
- [ ] 29以降: [要加筆]


### NASM_Tutorial:[NASM Assembly Tutorial](https://www.tutorialspoint.com/assembly_programming/assembly_quick_guide.htm)
- [ ] 01:Home
- [ ] 02:Introduction
- [x] 03:Environment Setup
- [x] 04:Basic Syntax
- [ ] 05:Memory Segments
- [ ] 06:Registers
- [ ] 07:System Calls
- [ ] 08:Addressing Modes
- [ ] 09:Variables
- [ ] 10:Constants
- [ ] 11:Arithmetic Instructions
- [ ] 12:Logical Instructions
- [ ] 13:Conditions
- [ ] 14:Loops
- [ ] 15:Numbers
- [ ] 16:Strings
- [ ] 17:Arrays
- [ ] 18:Procedures
- [ ] 19Recursion
- [ ] 20:Macros
- [ ] 21:File Management
- [ ] 22:Memory Management
