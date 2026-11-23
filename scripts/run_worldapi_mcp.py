"""Start the official WorldAPI MCP, reusing the ignored local server credential."""
import os
from pathlib import Path
import shutil
import sys
import yaml

root = Path(__file__).resolve().parents[1]
config = root / ".local/instances/fabric-26.3/config/worldapi/config.yml"
env = os.environ.copy()
env.setdefault("WORLDAPI_URL", "http://127.0.0.1:8110/api/v1")
if not env.get("WORLDAPI_TOKEN") and config.exists():
    data = yaml.safe_load(config.read_text())
    env["WORLDAPI_TOKEN"] = data["auth"]["tokens"][0]["token"]
entry = root / ".local/tools/node_modules/@mairwunnx/minecraft-mcp/dist/index.js"
node = shutil.which("node")
if not node or not entry.exists():
    sys.exit("Install Node and the pinned official Minecraft MCP first; see docs/verification.md")
os.execve(node, [node, str(entry)], env)
