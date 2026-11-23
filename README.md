# Minecraft

あかげふのMinecraft Java Edition計算機、シミュレーション、schematic生成、配置・検証ツールの管理リポジトリ。

## 制約

既存計算機の基準は **Java Edition 1.20.1**。信号強度0–15、減衰、コンパレーター、リピーター、更新順序、ピストン、ゲームtickの規則を保持する。コマンドやスクリプトは配置・観測・入力に使い、計算結果を代わりに生成しない。新しい版でのツール試験は既存回路の互換性証明ではない。

Project Red、Simply Redstone Systems、Automated Redstoneなどの追加回路素子はこの計算機には使わない。Paper/FAWEへの移行も基準環境の動作確認としては扱わない。

## 内容

| リポジトリルートからのパス | 内容 |
|---|---|
| `calculator/matlab/` | 復元した数値モデル・ROM出力・観測コード。元ファイルは保存 |
| `calculator/audit/` | 固定小数点モデルのC++誤差探索とPython多倍長照合 |
| `modpacks/` | packwizの配布元・版・ハッシュ。Mod本体は含まない |
| `scripts/` | 既存ツールの薄い呼び出しと、再実行可能な診断 |
| `docs/verification.md` | 導入結果、実動作の範囲、失敗・未検証 |
| `.local/` | ローカル専用のインスタンス・依存ツール・秘密情報。Git対象外 |

[導入済み環境の起動・再現手順](docs/setup.md)を参照。

## まず試す

Python 3.12、Java 17/21/25を用途ごとに使う。1.20.1はJava 17、1.21.1はJava 21、26.xはJava 25。

```sh
uv venv --python 3.12
uv pip install -r requirements.txt
.venv/bin/python scripts/schematic_smoke.py
clang++ -O2 -std=c++17 calculator/audit/audit.cpp -o build/cordic-audit
build/cordic-audit
.venv/bin/python calculator/audit/crosscheck.py
.venv/bin/python calculator/audit/check_translation.py
```

schematic診断は36ブロックの赤石粉の配線を生成する。`build/schematic-smoke/dust-line.schem`をWorldEditで貼り付け、Litematicaで照合する。これはツールの診断用で、CORDIC回路を生成したものではない。

ローカル1.20.1検証サーバーのAutoJSが起動している場合:

```sh
.venv/bin/python scripts/autojs.py
.venv/bin/python scripts/redstone_smoke.py
```

`redstone_smoke.py`は専用テストワールドの小領域を書き換える。既存ワールドには実行しない。

## Mod管理

`modpacks/fabric-1.20.1/`が基準ツール、`modpacks/fabric-1.21.1/`がAutoBuild/Lite2Editの独立検証用。packwizの版は固定し、更新時に依存関係と実ゲームを再確認する。AutoJSは配布元がModパック同梱を禁止しているため、ローカルの個別導入として分離する。

ゲーム音は検証インスタンスでミュートする。外部操作口はloopbackに限定する。秘密情報は公開ファイルにもGitの著者情報にも入れず、公開前に `python scripts/check_privacy.py` で追跡ファイルと全履歴を確認する。公開リポジトリにゲームのアカウントファイル、電話番号、メールアドレス、トークン、ワールド、ログを入れない。

## 数値モデルと実回路

誤差監査は保存された固定小数点数値モデルの検証であり、赤石回路の配線やタイミングを検証したものではない。従来の「乱数サンプルの最大誤差」と全入力範囲の探索を区別する。監査の浮動小数点ガードも、形式的な区間演算証明とは区別する。

C++版の数値演算は、独立したDecimal・整数モデルと境界値・乱数入力で照合する。コピーした実回路でも、リセット完了を待つ手順により、読み込まれた12.3度相当の正弦・余弦がモデルと一致した。[実回路の観測と結果](docs/calculator-debugger.md)、[C++翻訳の確認結果](verification/calculator-cpp-translation.json)を参照。

既存CORDIC回路の自動配置と出力照合には、実回路のschematicと入力・出力位置、リセット・クロック・完了条件の対応付けが必要。数値モデルからブロック配置が一意に定まるとは扱わない。

公開動画: [Minecraft JE Redstone 三角関数sin,cos計算機](https://www.youtube.com/watch?v=k6dFtVdtbHQ)。関連する数学的背景: [N進数展開の一般化と分解について](https://mathlog.info/articles/2625)。

第三者ツール・依存物のライセンスはそれぞれの配布元に従う。このリポジトリ全体の新しいライセンス許諾はまだ設定していない。
