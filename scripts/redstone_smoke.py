"""Diagnostic only: vanilla dust attenuation on a dedicated disposable world.

Uses normal setblock updates; does not change gamerules, ticks or redstone code.
"""
import json
import time
from pathlib import Path
from autojs import evaluate


def main():
    evaluate('AutoJS.command("forceload add 0 0 32 0");AutoJS.command("fill 0 80 8 18 82 8 air");AutoJS.command("fill 0 80 8 18 80 8 stone");AutoJS.command("fill 1 81 8 17 81 8 redstone_wire");AutoJS.command("setblock 0 81 8 redstone_block")')
    time.sleep(0.5)
    result = evaluate('var out=[];for(var x=1;x<=17;x++){out.push(""+AutoJS.blockAt(x,81,8));}JSON.stringify(out)')
    states = json.loads(result["value"])
    import re
    powers = [int(re.search(r"power=(\d+)", state)[1]) for state in states]
    assert powers == [max(0, 16 - x) for x in range(1, 18)], powers
    evaluate('AutoJS.command("fill 0 80 8 18 82 8 air")')
    cleared = json.loads(evaluate('AutoJS.blockInfo(0,81,8)')["value"])
    assert cleared["air"]
    output = {"kind": "tooling diagnostic, not calculator acceptance", "dust_power": powers, "cleanup": True}
    Path("build").mkdir(exist_ok=True)
    Path("build/redstone-smoke.json").write_text(json.dumps(output, indent=2) + "\n")
    print(json.dumps(output))


if __name__ == "__main__":
    main()
