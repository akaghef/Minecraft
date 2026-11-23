# ローカルでの入口

以下のパスはすべてリポジトリルートを基準にする。ゲーム・認証・ワールドは公開ファイルに含まれない。

## ランチャーのmain

このMacの`main`起動構成は`.local/instances/calculator-verification/`を使用する。元の4ワールドのコピーがあり、原本の`MinecraftUser/Fabric2/saves/`を起動先にしない。既存構成の古いホームディレクトリ指定による`INVALID_CONFIG`を修正して、ランチャーから起動できることを確認した。

Minecraftは1.20.1。元のModを維持し、観測用AutoJS/Rhinoの依存条件に合わせてFabric Loaderを0.18.4、Fabric APIを0.92.12へ更新した。計算機の起動キーとデバッガーの説明は[既存計算機の起動・観測・照合](calculator-debugger.md)を参照する。

## 既存計算機の完全ログ照合

専用の複製インスタンスは`.local/instances/calculator-complete-log/`。起動する場合は、そのディレクトリでJava 17を使用する。これは`main`で開いているクライアントとは別の作業コピーである。

```sh
/path/to/java17/bin/java -Xmx1G -Dautojs.port=25585 -jar fabric-server-launch.jar nogui
```

サーバーコンソールで`tick freeze`を実行し、停止中であることを確認する。次の操作はサーバーを再開し、リセット完了を観測してから1回だけ起動する。通常速度では約3分で回路自身の停止まで収録する。進行中のクライアントワールドには実行しない。

以下のコマンドは、リポジトリルートで実行する。

```sh
python scripts/autojs.py --script scripts/record_core_readout.js
python scripts/decode_core_readout.py \
  .local/instances/calculator-complete-log/core-readout.jsonl \
  .local/verification/calculator-develop-debugger/core-readout.json \
  --csv .local/verification/calculator-develop-debugger/core-readout.csv \
  --input-load-clock 560
```

2本目は収録完了後に実行する。途中のログは受理しない。`--input-load-clock`は確認した角度読込時刻を報告へ添える指定で、正弦・余弦の位相や値を選ぶ条件ではない。

収録スクリプトは専用コピーのパス・停止状態・既存ログがないことを確認する。再試験する場合は、前回の`core-readout.jsonl`を非公開の検証フォルダーへ退避してから実行する。終了は専用サーバーコンソールで`save-all flush`、`stop`。原本ワールドには操作しない。

## MATLAB接続

追加のMathWorksサインインを要求しない。このMacのCodex側MATLAB接続は`--matlab-session-mode existing`に固定する。既定の`auto`は既存セッションへ接続できないと新規起動へ移るため使用しない。既存の認証済みR2026aへ接続できることが確認できなければ、Pythonモデルと保存済みMATLAB照合結果を使う。`-batch`で別プロセスを起動しない。接続設定の変更は次の接続から有効であり、現在の接続が認証済みであるという主張ではない。

## PythonとNode

```sh
uv venv --python 3.12
uv pip install -r requirements.txt
npm install --prefix .local/tools minecraft-agent@1.0.8 awesome-mineflayer-mcp@1.3.2 @mairwunnx/minecraft-mcp@5.0.0
python scripts/install_modpacks.py 1.20.1
python scripts/install_modpacks.py 1.21.1
```

その他のツールの取得元とコミットは`tools.lock.json`、個別の合否は`docs/verification.md`を参照する。不合格のツールは計算機検証の経路に組み込まない。

## 今回導入したクライアントを起動

既存ランチャーの購入済みプロフィールと、導入済みのFabric版・ライブラリを再利用する。`--java`へ対象版のJava実行ファイルを渡す。認証を勝手にやり直さず、トークンを表示しない。

```sh
python scripts/launch_client.py 1.20.1 --java /path/to/java17/bin/java
python scripts/launch_client.py 1.21.1 --java /path/to/java21/bin/java
python scripts/launch_client.py 26.2 --java /path/to/java25/bin/java
python scripts/launch_client.py 26.3 --java /path/to/java25/bin/java
```

ゲーム音は0。Blockpalの音声出力・音声入力も無効にする。MC-CLI導入版はヘッドレスになる。1.20.1/1.21.1のゲームディレクトリは`.local/instances/fabric-<version>/`。既存の普段のゲームディレクトリを上書きしない。

## 今回の専用サーバーを再起動

`.local/instances/fabric-1.20.1/`へ移動し、Java 17で以下を実行する。終了はコンソールの`stop`。このインスタンスは診断用ワールドで、RCONはloopbackに限定している。

```sh
/path/to/java17/bin/java -Xmx1G -Dautojs.port=25585 -jar fabric-server-launch.jar nogui
```

WorldAPI用は`.local/instances/fabric-26.3/`でJava 25を使用する。HTTPの入口は`http://127.0.0.1:8110/api/v1`。認証情報は同インスタンスの`config/worldapi/config.yml`にあり、公式MCPの起動ラッパーが内部で読み込む。

クライアントのAutoJSは`http://127.0.0.1:25586/mcp`。Codexでこのリポジトリをプロジェクトとして開くと`.codex/config.toml`の接続を使う。現在のチャットへ新規ツールが動的に追加されたことは意味しない。ローカルSDKからの実呼出しは別途検証している。

AutoJSは配布元の指示に従い個別導入とし、公開Modパックには含めない。回路やワールドの算術規則を変更する拡張は追加しない。
