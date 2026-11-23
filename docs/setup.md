# ローカルでの入口

以下のパスはすべてリポジトリルートを基準にする。ゲーム・認証・ワールドは公開ファイルに含まれない。

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
