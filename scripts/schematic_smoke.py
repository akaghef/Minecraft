"""Diagnostic fixture: generate .schem and verify its .litematic round trip.

This exercises format tooling, not the CORDIC calculator. Requires Python 3.12.
"""
import json
from pathlib import Path
import mcschematic
from nucleation import Schematic


def blocks():
    result = {(x, 0, 0): "minecraft:stone" for x in range(18)}
    result[(0, 1, 0)] = "minecraft:redstone_block"
    for x in range(1, 18):
        result[(x, 1, 0)] = "minecraft:redstone_wire[east=side,north=none,power=0,south=none,west=side]"
    return result


def main():
    out = Path("build/schematic-smoke")
    out.mkdir(parents=True, exist_ok=True)
    expected = blocks()
    schem = mcschematic.MCSchematic()
    for pos, block in expected.items():
        schem.setBlock(pos, block)
    schem.save(str(out), "dust-line", mcschematic.Version.JE_1_20_1)
    original = Schematic.from_schematic((out / "dust-line.schem").read_bytes())
    original.save(out / "dust-line.litematic")
    roundtrip = Schematic.from_litematic((out / "dust-line.litematic").read_bytes())
    for pos in expected:
        a, b = str(original.get_block(*pos)), str(roundtrip.get_block(*pos))
        assert a == b, (pos, a, b)
    result = {"kind": "tooling diagnostic", "blocks": len(expected), "roundtrip_differences": 0}
    (out / "result.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result))


if __name__ == "__main__":
    main()
