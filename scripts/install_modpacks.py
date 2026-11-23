"""Install pinned Modrinth artifacts into isolated local instances.

Does not copy account data, worlds, or third-party debug tools into a modpack.
"""
import argparse
import hashlib
import json
from pathlib import Path
import urllib.request

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("version", choices=["1.20.1", "1.21.1"])
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
records = json.loads((root / "modpacks/versions.lock.json").read_text())
target = root / ".local/instances" / ("fabric-" + args.version) / "mods"
target.mkdir(parents=True, exist_ok=True)
installed = 0
for record in records:
    if record["minecraft"] != args.version:
        continue
    name = record["filename"]
    if Path(name).name != name:
        raise ValueError("The pinned filename is not a basename")
    file = target / name
    if file.exists():
        if hashlib.sha512(file.read_bytes()).hexdigest() != record["sha512"]:
            raise RuntimeError(f"Existing file differs from the lock; preserved: {name}")
        continue
    request = urllib.request.Request(record["url"], headers={"User-Agent": "Minecraft-circuit-tools/0.1"})
    with urllib.request.urlopen(request, timeout=60) as response:
        data = response.read()
    if hashlib.sha512(data).hexdigest() != record["sha512"]:
        raise RuntimeError(f"Download hash mismatch: {name}")
    with file.open("xb") as stream:
        stream.write(data)
    installed += 1
print(f"Verified all pinned files for {args.version}; installed {installed} missing files.")
