# SDMを読み解く
## SDMとは
- Software Developer's Manualの略
- Intelが公開しているIntelプロセッサのアーキテクチャとプログラミングに関するドキュメント
- [SDM](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)

## SDMの概要
- Volume1:Basic Architecture
  - アーキテクチャとプログラミングの概要
- Volume2:Instruction Set Reference, A-Z
  - 全ての命令セット(Instruction Set)の詳細が記載されている
- Volume3:System Programming Guide
- Volume4:Model-specific Registers

# Volume2
## Chapter2 Instruction Format

## Chapter3,4,5 Instruction Set Reference
- Instruction Setの説明を読めるようになる
- [SDM](https://www.intel.co.jp/content/dam/www/public/ijkk/jp/ja/documents/developer/EM64T_VOL1_30083402_i.pdf) P.73
- 例:[mov](SDM.md)

| words           | means                                                |
| --------------- | ---------------------------------------------------- |
| Opecode         | 命令のオペコード。機械語。                           |
| Instruction     | 命令の書式                                           |
| Op/En           | Operand Encoding。オペランド。各命令ごとに定義される |
| 64-Bit Mode     | 64ビットモード。サポートの有無。                     |
| Compat/Leg Mode | 互換/レガシーモード。サポートの有無。                |
| Descrption      | 説明                                                 |

### Instruction
- 命令の書式が記述されている
- `命令 第一オペランド, 第二オペランド`のような形
- オペランドの記述の仕方(r/m8等)
  - r:レジスタ
  - m:メモリ
  - imm:即値
  - Sreg:セグメントレジスタ
  - レジスタ:レジスタ名
  - 数値:bit数

### Exceptions
| Vector No. |                                                | 発生源                                                           |
| ---------- | ---------------------------------------------- | ---------------------------------------------------------------- |
| 0          | #DE - 除算エラー                               | DIV および IDIV 命令                                             |
| 1          | #DB - デバッグ                                 | 任意のコードまたはデータ参照                                     |
| 3          | #BP - ブレークポイント                         | INT 3 命令                                                       |
| 4          | #OF - オーバーフロー                           | INTO 命令                                                        |
| 5          | #BR - BOUND 範囲外                             | BOUND 命令                                                       |
| 6          | #UD - 無効オペコード                           | UD2 命令または予約オペコード                                     |
| 7          | #NM - デバイスなし（算術演算コプロセッサなし） | 浮動小数点またはWAIT/FWAIT 命令                                  |
| 8          | #DF - ダブルフォルト                           | 例外、 NMI、またはINTR を発生する可能性がある任意の命令          |
| 10         | #TS - 無効 TSS                                 | タスクスイッチまたは TSS アクセス                                |
| 11         | #NP - セグメントなし                           | セグメント・レジスタのロードまたはシステム・セグメントのアクセス |
| 12         | #SS - スタック・セグメント・フォルト           | スタック操作およびSS レジスタロード                              |
| 13         | #GP - 一般保護                                 | * 任意のメモリ参照およびその他の保護チェック                     |
| 14         | #PF - ページフォルト                           | 任意のメモリ参照                                                 |
| 16         | #MF - 浮動小数点エラー（算術演算フォルト）     | 浮動小数点またはWAIT/FWAIT 命令                                  |
| 17         | #AC - アライメント・チェック                   | 任意のメモリデータ参照                                           |
| 18         | #MC - マシンチェック                           | マシン・チェック・エラーはモデルに依存                           |
| 19         | #XF - SIMD 浮動小数点数値エラー                | SSE および SSE2 浮動小数点命令                                   |

# 引用、参考
- https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html
- https://www.intel.co.jp/content/dam/www/public/ijkk/jp/ja/documents/developer/EM64T_VOL1_30083402_i.pdf