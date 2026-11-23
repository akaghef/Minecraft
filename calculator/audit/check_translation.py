"""Compare compiled C++ evaluation with the independent Decimal/integer model."""
import contextlib
import io
import json
import os
from pathlib import Path
import random
import runpy
import subprocess


def main():
    root = Path(__file__).resolve().parents[2]
    build = root / "build" / "translation-check"
    build.mkdir(parents=True, exist_ok=True)
    source = root / "calculator/audit/audit.cpp"
    harness = build / "evaluate.cpp"
    harness.write_text('''#define main audit_search_main
#include "audit.cpp"
#undef main
#include <iostream>
int main() {
    Audit latest(true), earlier(false);
    I angle;
    while (std::cin >> angle) {
        Point a=latest.evaluate(angle), b=earlier.evaluate(angle);
        std::cout << "value " << angle << ' ' << a.x << ' ' << a.y
                  << ' ' << b.x << ' ' << b.y << '\\n';
    }
}
''')
    binary = build / "evaluate"
    subprocess.run([os.environ.get("CXX", "c++"), "-O2", "-std=c++17",
                    "-Wall", "-Wextra", "-Wpedantic", "-fsanitize=undefined",
                    "-fno-sanitize-recover=all", "-I", str(source.parent),
                    str(harness), "-o", str(binary)], check=True)
    with contextlib.redirect_stdout(io.StringIO()):
        model = runpy.run_path(str(source.with_name("crosscheck.py")))
    maximum = 9_000_000_000_000
    angles = {0, 1, maximum - 1, maximum, 1_230_000_000_000,
              4_500_000_000_000, 7_000_000_000_000}
    # Include exact coarse decision boundaries and the integer on either side.
    centers = {model["coarse"][0]}
    for step in model["coarse"][1:7]:
        centers = {c + sign * step for c in centers for sign in (-1, 1)}
        angles.update(c + d for c in centers for d in (-1, 0, 1)
                      if 0 <= c + d <= maximum)
    seed = random.Random(20261123)
    angles.update(seed.randrange(maximum + 1) for _ in range(2000))
    angles = sorted(angles)
    output = subprocess.check_output([str(binary)],
              input="".join(f"{a}\n" for a in angles), text=True)
    rows = [list(map(int, line.split()[1:])) for line in output.splitlines()
            if line.startswith("value ")]
    if len(rows) != len(angles):
        raise AssertionError("Compiled evaluator did not return every input")
    different_variants = 0
    for angle, row in zip(angles, rows):
        tick, *values = row
        if tick != angle:
            raise AssertionError("Input ordering changed")
        for latest, actual in ((True, values[:2]), (False, values[2:])):
            expected = model["direct"](angle, latest)
            if tuple(actual) != expected:
                raise AssertionError(f"C++ translation mismatch at {angle}, latest={latest}")
        different_variants += values[:2] != values[2:]
    if not different_variants:
        raise AssertionError("The cases did not distinguish the two held-value variants")
    cos, sin = model["direct"](1_230_000_000_000, True)
    report = {"scope": "Compiled C++ numerical translation, not circuit physics",
              "reference": "Independent Decimal constants and integer updates in crosscheck.py",
              "input_degrees_range": [0, 90], "angle_scale": 10**11,
              "cases_per_variant": len(rows), "variants": ["cordic_latest", "cordic_error"],
              "mismatches": 0, "cases_distinguishing_variants": different_variants,
              "undefined_behavior_sanitizer": "passed",
              "input_12_3": {"sin_fixed": sin, "cos_fixed": cos, "scale": 10**12}}
    target = root / "verification/calculator-cpp-translation.json"
    target.write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
