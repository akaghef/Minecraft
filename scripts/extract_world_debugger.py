"""Read every saved command block using the existing NBT region library.

This is a read-only inventory, not a simulator. Output may contain private world
data and must remain in ignored local storage.
"""
import argparse
from collections import Counter
import json
from pathlib import Path

from nbt.nbt import NBTFile, TAG_Compound, TAG_List
from nbt.region import RegionFile


def plain(tag):
    if isinstance(tag, TAG_Compound):
        return {child.name: plain(child) for child in tag.tags}
    if isinstance(tag, TAG_List):
        return [plain(child) for child in tag.tags]
    value = tag.value
    return list(value) if hasattr(value, "typecode") else value


def block_state(chunk, tile):
    x, y, z = (tile[k] for k in ("x", "y", "z"))
    section = next(s for s in chunk["sections"] if s["Y"] == y // 16)
    states = section["block_states"]
    palette = states["palette"]
    if len(palette) == 1:
        return palette[0]
    bits = max(4, (len(palette) - 1).bit_length())
    per_word = 64 // bits
    index = ((y & 15) << 8) | ((z & 15) << 4) | (x & 15)
    word, offset = divmod(index, per_word)
    entry = (states["data"][word] >> (offset * bits)) & ((1 << bits) - 1)
    return palette[entry]


def extract(world):
    commands, errors, coverage = [], [], []
    regions = sorted(p for p in world.rglob("r.*.*.mca") if p.parent.name in {"region", "entities"})
    for path in regions:
        scanned = 0
        with path.open("rb") as stream:
            region = RegionFile(fileobj=stream)
            for location in region.get_chunk_coords():
                try:
                    chunk = plain(region.get_nbt(location["x"], location["z"]))
                    for tile in chunk.get("block_entities", []) + chunk.get("Entities", []):
                        if tile.get("id") not in {"minecraft:command_block", "minecraft:command_block_minecart"}:
                            continue
                        row = {"region_file": str(path.relative_to(world)), "nbt": tile}
                        if tile["id"] == "minecraft:command_block":
                            row["block_state"] = block_state(chunk, tile)
                        commands.append(row)
                    scanned += 1
                except Exception as exc:
                    errors.append({"file": str(path.relative_to(world)), "chunk": location,
                                   "error": str(exc)})
        coverage.append({"file": str(path.relative_to(world)), "chunks_read": scanned})
    functions = {str(p.relative_to(world)): p.read_text() for p in sorted(world.glob("datapacks/**/*.mcfunction"))}
    tags = {str(p.relative_to(world)): json.loads(p.read_text()) for p in sorted(world.glob("datapacks/**/tags/functions/*.json"))}
    scripts = {str(p.relative_to(world)): p.read_text() for p in sorted(world.glob("scripts/**/*.sc"))}
    scoreboard = world / "data/scoreboard.dat"
    scores = plain(NBTFile(filename=str(scoreboard))) if scoreboard.exists() else None
    return {"world_directory": str(world), "region_coverage": coverage, "errors": errors,
            "command_blocks": commands, "functions": functions, "function_tags": tags,
            "carpet_scripts": scripts, "scoreboard": scores}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("world", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    if not (args.world / "level.dat").is_file():
        parser.error("world must contain level.dat")
    if args.output.exists():
        parser.error("output exists; keep the previous inventory")
    result = extract(args.world.resolve())
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    verbs = Counter(row["nbt"].get("Command", "").lstrip("/").split(" ", 1)[0]
                    for row in result["command_blocks"])
    print(json.dumps({"region_files": len(result["region_coverage"]),
                      "chunks_read": sum(r["chunks_read"] for r in result["region_coverage"]),
                      "command_blocks": len(result["command_blocks"]), "command_verbs": verbs,
                      "functions": len(result["functions"]), "errors": len(result["errors"])},
                     ensure_ascii=False))
    return bool(result["errors"])


if __name__ == "__main__":
    raise SystemExit(main())
