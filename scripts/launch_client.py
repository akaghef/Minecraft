"""Launch an isolated installed Fabric client using the existing purchased profile.

Tokens stay in memory and are never printed. Does not initiate a sign-in flow.
"""
import argparse
import json
import os
from pathlib import Path
import subprocess
import sys
from minecraft_launcher_lib.command import get_minecraft_command

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("version", choices=["1.20.1", "1.21.1", "26.2", "26.3"])
parser.add_argument("--java", required=True, help="Java executable for this Minecraft version")
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
mc = Path(os.environ.get("MINECRAFT_DIR", Path.home() / "Library/Application Support/minecraft"))
account_data = json.loads((mc / "launcher_accounts.json").read_text())
accounts = account_data["accounts"]
active = accounts.get(account_data.get("activeAccountLocalId", ""))
if not active or not active.get("minecraftProfile"):
    active = next((v for v in accounts.values() if v.get("minecraftProfile", {}).get("name") == "Akaghef2"), None)
if not active:
    sys.exit("No existing purchased Minecraft profile was found in the launcher.")
profile = active["minecraftProfile"]
game = root / ".local/instances" / ("fabric-" + args.version)
game.mkdir(parents=True, exist_ok=True)
options = game / "options.txt"
lines = options.read_text().splitlines() if options.exists() else []
options.write_text("\n".join(line for line in lines if not line.startswith("soundCategory_master:")) + "\nsoundCategory_master:0.0\n")
blockpal = game / "config/blockpal/config.json"
if blockpal.exists():
    config = json.loads(blockpal.read_text())
    config["voiceResponses"] = False
    config["allowVoice"] = False
    blockpal.write_text(json.dumps(config, indent=2) + "\n")
loader = "0.18.4" if args.version == "1.20.1" else "0.20.1"
opts = {"username": profile["name"], "uuid": profile["id"], "token": active.get("accessToken", ""),
        "gameDirectory": str(game), "executablePath": args.java,
        "jvmArguments": ["-Xmx2G", "-XstartOnFirstThread", "-Dautojs.port=25586", "-Dmccli.headless=true"],
        "launcherName": "Minecraft circuit tools", "launcherVersion": "0.1.0"}
command = get_minecraft_command(f"fabric-loader-{loader}-{args.version}", mc, opts)
with (game / "client-launch.log").open("w") as log:
    result = subprocess.run(command, cwd=game, stdout=log, stderr=subprocess.STDOUT)
sys.exit(result.returncode)
