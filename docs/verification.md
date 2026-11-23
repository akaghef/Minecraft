# 導入・検証記録

検証日: 2026-11-23。対象はこのMac上の独立したテストインスタンス。既存ワールド・元のModフォルダー・Microsoftアカウントの設定は変更していない。ゲーム音量は0。

**総合判定: 全件合格ではない。** 配布停止、対応環境の相違、実動作不合格がある。インストール・初期化・機能検証を区別する。以下の診断は小さな固定の配線・構造を使ったツール試験であり、既存CORDIC計算機の受入試験ではない。

## 回路規則に関する不合格

[Minecraft Redstone MCP](https://github.com/dylan121322/minecraft-redstone-mcp)はMCP起動・36ツールの取得・ボット接続まで成功した。しかし現行の`mcp-server/scripts/nucleation_bridge.py`の`main()`は`simulate_logic()`を呼び、`simulation_type=logic`を返す。ブロックの接続・伝搬遅延の検証になっていない。未知の論理ゲート等では期待値をactualへ代入する経路もある。

同じNOT回路について、トーチを残したケースと除去したケースの**両方がpassed=true**になった。[再現入力と結果](../verification/redstone-mcp-counterexample.json)を保存した。この合格表示を回路の正しさの証拠に採用しない。回路検証用のCodex接続としても有効化していない。必要な修正は、実ブロックシミュレーションを実行し、未対応や実行失敗を不合格として返すこと。期待値からの出力生成を検証経路から除くこと。

## ツール別の確認範囲

| ツール | 導入・確認結果 | 限界・停止理由 |
|---|---|---|
| [Litematica](https://modrinth.com/mod/litematica) 0.15.4 / MaLiLib 0.16.3 | 1.20.1実クライアントでlitematic読込、配置登録、描画有効化、材料3種類・36個、検証GUIを確認。36個のブロック種別一致、欠損0、余分0 | 通電による15個のpower状態差を検出。無視設定で隠していない |
| [AutoSchm](https://www.autoschm.net/) | 公式配布先を調査 | 公式サイトがAccount Suspendedへ転送され、取得不能。導入していない |
| [AutoBuild](https://modrinth.com/mod/autobuild) 2.0.1+1.21.1 | 独立したFabric 1.21.1に導入。実プレイヤーでschem読込、材料一覧、速度指定、36ブロックの自動配置を実行。別のボット読取で全36種別と17個の赤石粉の信号強度を照合 | 1.20.1非対応。クライアント専用と扱わず、パック内ではside=both |
| [WorldEdit](https://modrinth.com/plugin/worldedit) 7.2.15 | 1.20.1実ワールドでAPI経由の設置、schem保存・読込・貼付、読み戻しを確認。生成配線の通電も確認 | FAWE/Paperへの置換はしていない |
| [Applied Automata](https://www.curseforge.com/minecraft/mc-mods/applied-automata) 1.0.1 | NeoForge 1.21.1・AE2 19.2.20・GuideME・Rhinoで起動。station読込、ME drive接続・給電、材料投入、ドローン建築開始まで確認 | 36ブロックの入力に対し19タスクとなり、1個だけのはずのredstone blockを追加要求して停止。投入したstone18・redstone17が残り、redstone block1だけ消費された。元のschematicどおりの完成を確認できず不合格。原因は未確定 |
| [Lite2Edit](https://github.com/Erik-Donath/Lite2Edit) 1.0 | 1.21.1 WorldEditへlitematica形式が登録された。litematicを読込→schem保存し、nucleationで全36ブロック状態が元と一致 | 1.20.1非対応 |
| [WorldAPI](https://github.com/MairwunNx/minecraft-worldapi) 4.6.1 | Fabric 26.3で起動。HTTP設置→読取→undo→元のairへ戻ったことを確認。公式minecraft-mcp 5.0.0の認証済み45ツール、状態取得・ブロック読取も確認 | 26.3の結果は1.20.1回路の互換性証明ではない。HTTPは127.0.0.1へ変更 |
| [AutoJS](https://github.com/MerrySnow404/AutoJS) 1.0.1 | Fabric 1.20.1 / NeoForge 1.21.1でMCPを確認。設置・読取・撤去、ゲーム状態・GUIの取得、他Modの実API呼出しを確認 | 配布元の指示によりModパックへ同梱せずローカル個別導入 |
| [Forge AI Bridge](https://www.curseforge.com/minecraft/mc-mods/forge-ai-bridge) | 公式対応環境・ファイルを特定 | JARダウンロードがHTTP 403。未導入 |
| [Blockpal AI](https://www.curseforge.com/minecraft/mc-mods/blockpal-ai) 3.27.0 | Fabric 26.2で起動。外部AI自動接続をMCPモードへ切替。localhostのMCP listenerを確認 | コンパニオンの自律建築は未検証。外部の無料AIサービスによる試験は実行していない |
| [RemoteControllerMod](https://github.com/takecx/RemoteControllerMod) 1.1.0+1.20.1 | 配布JARを取得し、Forge 47系依存を確認 | 公式Forge installer取得がHTTP 403。ロード・操作は未検証 |
| Project Red / Simply Redstone Systems / Automated Redstone | 導入しない | 追加回路素子・信号規則の変更を今回の計算機に使わないという制約による |
| [mcschematic](https://github.com/Sloimayyy/mcschematic) 11.4.4 | 36ブロックのschemを生成。WorldEdit・AutoBuild・mcbから実配置 | CORDICの全ブロック配置を生成したものではない |
| [nucleation](https://github.com/Schem-at/Nucleation) 0.12.4 | Python 3.12のmacOS wheelで導入。schem→litematic→読戻し36状態一致、SchemConvert/Lite2Editの結果との照合 | Python 3.11ではソースビルドになり古いCargoで失敗したため3.12を使用。回路シミュレーターの同等性は未認定 |
| [SchemConvert](https://github.com/PiTheGuy/SchemConvert) 1.2.6 | mcschematicのschem→litematic→schemで36状態一致 | nucleation生成のlitematicを入力すると変換エラー。この組合せは不合格のまま記録 |
| [mctools](https://pypi.org/project/mctools/) 1.4.1 | RCON認証・設置・撤去。独立したAutoJSで設置後stone、撤去後airを確認 | loopbackのテストサーバーのみ |
| [blockwright](https://github.com/ThatHunky/blockwright) | ソースから依存導入・ビルド、MCP初期化と22ツールを確認 | 1.20.1の`server_info`でRCON connection closed。同じサーバーでmctoolsは成功。上流RCON実装はコマンド直後にsentinelを送る。互換性修正が必要。独自の代替サーバーや判定変更は加えていない |
| [minecraft-agent](https://github.com/justjavac/minecraft-agent) 1.0.8 | loopbackの専用ボット用サーバーへ接続、状態・位置・移動・ブロック状態取得。AutoBuild結果の全36ブロックを読み戻した | オフライン認証は新規のローカル試験環境のみ。既存環境の認証設定は維持 |
| [MC-CLI](https://github.com/Th0rgal/mc-cli) 1.6.0 | Fabric 26.3を無音ヘッドレス起動。ワールド作成、状態取得、PNG capture、設置・ブロック読取・撤去を確認 | 旧1.20.1環境へは混在させていない |
| [mineflare-cli](https://github.com/eastlondoner/mineflare-cli) 1.4.5 | macOS arm64配布物・CLIを取得。Bunを導入し公式ソース実行も試行 | 配布物が開発元の絶対パスのbot-process.jsを参照して失敗。ソース版もspawn後healthのbotConnected=false、state HTTP 400で未合格。停止済み |
| [McClaude](https://github.com/lightningreflex/mcclaude) | MCP側を導入・ビルド、14ツール初期化 | ライブ接続は未構成。配布元のユーザークライアントはWindows専用のドライブマウントを使い、Paper 1.21+プラグインを前提とする。既存Fabric回路環境をPaperへ変更しない |
| [Minecraft Builder MCP](https://github.com/3-03/minecraft-builder-mcp) | 20ツール初期化。既存テストサーバーに接続し、状態取得とRCON設置・撤去を確認 | このツール独自のserver_startによる別環境の構築は実行していない |
| [minecraft-builder-skill](https://github.com/wzhaoMS/minecraft-builder-skill) | 標準skill-installerでプロジェクトへ導入、CLI依存導入。mcbから36ブロックをRCON配置、別系統で信号強度を読戻し | doctorはRCON成功、オンライン認証の基準サーバーへのオフラインbot接続は拒否。RCONのundo未対応を隠していない |
| [awesome-mineflayer-mcp](https://github.com/G0Osey99/awesome-mineflayer-mcp) 1.3.2 | 123ツール、実サーバーへのbot接続、状態取得、操作指示、切断を確認 | 全123機能を個別に網羅した試験ではない |
| [yuniko minecraft-mcp-server](https://github.com/yuniko-software/minecraft-mcp-server) 2.0.4 | 22ツール初期化。実サーバーで位置→500 ms前進→位置変化を確認 | 起動直後は接続中。spawnを待って確認 |
| [minecraft-structure-mcp](https://github.com/WebitroHQ/minecraft-structure-mcp) 0.5.0 | 26ツール、構造作成・石配置・NBT保存・等角描画。PNGも目視確認 | 外部AIへのAPIキー設定・課金は実行していない |
| [minecraft-plugin-development](https://github.com/github/awesome-copilot/tree/main/skills/minecraft-plugin-development) | 標準skill-installerで導入、SKILL.mdのfrontmatterと参照ファイルを確認 | Paperプラグイン開発用の手順。基準回路環境を変更する理由には使わない |
| Amaranth / Yosys / Icarus Verilog | AmaranthからVerilog生成、Yosys合成、Icarusの4入力組合せを確認 | 二値XORのツール診断であり、CORDICの信号強度・制御回路を検証したものではない |
| [V2MC](https://github.com/Kenny2github/V2MC) | 公式ソースを取得。公式DFFテストをYosysで合成、上流assemblyからDFF4のNBTを生成 | 完全な配置配線・実ゲームでの順序回路検証は未達。生成NBTだけで合格にしない |
| [MinecraftHDL](https://github.com/itsFrank/MinecraftHDL) | 配布元・要求環境を確認 | Forge 1.10.2を前提とする旧フロー。今回の版へ混ぜず、V2MCとPython schematic生成を検証対象にした |

## 数値資産

復元済みMATLABソースをコピーし、観測コード2本の個人環境の絶対パスだけを環境変数`MINECRAFT_FUNCTIONS_DIR`へ変更した。元のファイルは変更していない。`calc_time.m`の既知の構文・変数名問題は修正済みと主張していない。MATLABの新規ログインや再起動は行っていない。

C++誤差探索を再コンパイル・実行し、Python Decimal照合も再実行した。モデルの最大絶対誤差は約8e-11。これはモデルと浮動小数点ガードを含む数値監査であり、実ゲームのCORDIC出力や厳密な形式証明ではない。

既存Mod 14個のファイル名とSHA-512を`modpacks/existing-fabric-inventory.json`へ記録した。12個をModrinthの版へ対応付けた。既存ファイル本体は公開していない。

## Codex・公開範囲

`.codex/config.toml`にはWorldAPIの公式MCPとローカルAutoJSだけを接続する。WorldAPIの資格情報はGit対象外のローカル設定から起動時に読み、公開設定へ書かない。その他のMCPは独立したSDK診断で試験しており、全プロジェクトへ一括で自動起動させていない。

このプロジェクトだけをCodexのtrusted projectへ登録し、`codex mcp get minecraft_worldapi --json`でプロジェクト設定が読み込まれることを確認した。Skillはこのプロジェクトの`.agents/skills/`へ導入済みで、次にこのプロジェクトを開いたターンから利用できる。

追跡ファイルと全Git履歴を連絡先・資格情報検査の対象にする。第三者ソース・JAR・アカウント情報・ワールド・実行ログ・キャッシュ・ローカルMCP試験設定はGit対象外。画像は公開する場合に実際のピクセルを確認する。
