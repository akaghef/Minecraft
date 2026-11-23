"""Compare the first physical CORDIC update with the existing integer model.

Input is an actual AutoJS tick trace, not a constructed expected-value fixture.
This checks one coarse update only; it cannot certify the whole calculator.
"""
import argparse
import contextlib
import io
import json
from pathlib import Path
import runpy


def decode(row):
    raw = row["regs"]["A"]
    if len(raw) != 13 or any(v is None or not 0 <= v <= 15 for v in raw):
        raise ValueError("Invalid physical signal-strength samples")
    # Same offset and clamp as the existing getVal2.m/kensyou.m decoder.
    digits = [max(0, int(value) - 1) for value in raw]
    return sum(d * 10**i for i, d in enumerate(digits)) if max(digits) <= 9 else None


def compare(rows, input_tick):
    root = Path(__file__).resolve().parents[1]
    with contextlib.redirect_stdout(io.StringIO()):
        model = runpy.run_path(str(root / "calculator/audit/crosscheck.py"))
    start, angles = model["start"], model["coarse"]
    modulus = 10**13
    initial_theta = input_tick - angles[0]
    values = {int(r["age"]): decode(r) for r in rows}
    pulse = next(int(r["age"]) for r in rows if r.get("event") == "pulse1")
    # Find the three multiplexed initial registers and their observed period.
    starts = [a for a in sorted(values) if a > pulse and
              values[a] == initial_theta % modulus and
              values.get(a - 1) != initial_theta % modulus]
    for first in starts:
        width = 1
        while values.get(first + width) == initial_theta % modulus:
            width += 1
        if values.get(first + width) == start and values.get(first + 2 * width) == start:
            break
    else:
        raise ValueError("The model's initial theta/sin/cos state was not observed")
    period = 3 * width
    if values.get(first + period) != initial_theta % modulus:
        raise ValueError("The initial register rotation did not repeat")
    boundary = next(a for a in range(first + period, max(values) - 2 * width, period)
                    if values[a] != initial_theta % modulus)
    if any(values[a] is None for a in (boundary, boundary + width, boundary + 2 * width)):
        raise ValueError("Invalid digits at the first observed register update")
    sign = 1 if initial_theta >= 0 else -1
    expected = {"theta_unsigned": (initial_theta - sign * angles[1]) % modulus,
                "sin": start + sign * 4 * model["shift"](start, 1),
                "cos": start - sign * 4 * model["shift"](start, 1)}
    observed = {"theta_unsigned": values[boundary],
                "sin": values[boundary + width],
                "cos": values[boundary + 2 * width]}
    m1 = rows[first]["regs"]["M1"]
    return {"kind": "Conditional first coarse comparison; physical input source and phase unverified",
            "input_angle_fixed": input_tick, "angle_scale": 10**11,
            "input_evidence": {"external_source_verified": False,
                               "register_role_verified": False,
                               "input_written_by_this_run": False,
                               "observed_m1_at_initial_pattern": sum(int(v) * 10**i for i, v in enumerate(m1))},
            "phase_independently_verified": False,
            "value_scale": 10**12, "initial_gain_fixed": start,
            "initial_state_observed": True, "phase_width_game_ticks": width,
            "initial_theta_age": first, "first_update_age": boundary,
            "expected": expected, "observed": observed,
            "matches": {k: observed[k] == v for k, v in expected.items()},
            "passed": observed == expected}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("trace", type=Path)
    parser.add_argument("--input-angle-fixed", type=int, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    rows = [json.loads(line) for line in args.trace.read_text().splitlines()]
    if any("error" in row for row in rows):
        raise ValueError("The physical observation trace contains errors")
    result = compare(rows, args.input_angle_fixed)
    args.output.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result, indent=2))
    return not result["passed"]


if __name__ == "__main__":
    raise SystemExit(main())
