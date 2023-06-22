## 目的と縛り
- アセンブリ言語でCコンパイラを作成すること
- 目的を達成する前段階として、C言語でCコンパイラを作成中
  - [C_Compiler_for_CのGitHub](https://github.com/sotarokashiuchi/C_Compiler_for_C.git)

## 開発環境
|            | ツール バージョン                            |
| ---------- | -------------------------------------------- |
| OS         | Ubuntu 22.04.2 LTS                           |
| アセンブラ | NASM version 2.16.01 compiled on Jun 18 2023 |
| リンカ     | GNU ld (GNU Binutils for Ubuntu) 2.38        |

```shell
nasm -f elf64 -g -o main.o -l main.lts main.s
ld -m elf_x86_64 -o main.out main.o
./main.out > temp.s
nasm -f elf64 -g -o temp.o -l temp.lts temp.s
ld -m elf_x86_64 -o temp.out temp.o
./temp.s
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
- [ ] アセンブリ言語の基本を知る
  - [x] (2023/06/18)「書籍1:06:コンピュータの基本構成」
  - [x] (2023/06/19)「書籍1:07:CPUの基本機能」
  - [x] (2023/06/22)「書籍1:08:CPU命令の使い方」
  - [x] (2023/06/18)「書籍1:09:アセンブラ(NASM)の使い方」
  - [ ] 「書籍1:13:アセンブラによる制御構文と関数の記述例」(<---Now:2023/06/22)
- [ ] プログラムレビューをしやすいようにマニュアルを作成
- [ ] 「compilerbook:1:整数1個をコンパイルする言語の作成」
  - [ ] 出力:結果をシステムコールを通じて表示(<---Now:2023/06/22)
  - [ ] システムコールの理解を深める
  - [ ] 入力:データを取り込む 
  - [ ] test.shの導入
  - [ ] Makefileの作成
  - [ ] gitの設定
- [ ] 「compilerbook:2:加減算の実現」

## 資料
### 書籍1:作って理解するOS x86系コンピュータを動かす理論と実装
- [ ] コンピュータの基礎を理解する
  - [x] 01:(2023/06/15)ハードウェアの基礎
  - [ ] 02:ソフトウェアの基礎
  - [ ] 03:メモリ管理のしくみ
  - [ ] 04:ファイルシステムのしくみ
  - [ ] 05:入出力のしくみ
- [ ] x86系PCのアーキテクチャを理解する
  - [x] 06:コンピュータの基本構成
  - [x] 07:CPUの基本機能
  - [x] 08:CPU命令の使い方
  - [x] 09:アセンブラ(NASM)の使い方
  - [ ] 10:周辺機器の制御方法
  - [ ] 11:BIOSの役割
- [ ] OSを実装する
  - [x] 12:開発環境を構築する
  - [ ] 13:アセンブラによる制御構文と関数の記述例
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

### compilerbook:[低レイヤを知りたい人のためのCコンパイラ作成入門](https://www.sigbus.info/compilerbook) for Assembly
- [ ] 1：整数1個をコンパイルする言語の作成
- [ ] 2：加減算のできるコンパイラの作成
- [ ] 3：トークナイザを導入
- [ ] 4：エラーメッセージを改良
- [ ] 5：四則演算のできる言語の作成
- [ ] 6：単項プラスと単項マイナス
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
