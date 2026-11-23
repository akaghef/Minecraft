"""Recover the three multiplexed values from the real complete tick log.

Uses the clock conversion in getLog.m and phase offset in getVal2.m, never a
matching simulation value to choose the sine/cosine phase.
"""
import argparse
import csv
import json
from pathlib import Path


def decode(rows, input_load_clock=None):
    errors = [r for r in rows if "error" in r]
    if errors:
        raise ValueError(f"Observation failed: {errors[0]}")
    if rows[-1].get("terminal_reason") != "circuit_requested_freeze":
        raise ValueError("The circuit has not reached its own freeze endpoint")
    pulse_age = next(int(r["age"]) for r in rows if r.get("event") == "pulse1")
    samples = []
    cycles = {}
    epoch = 0
    previous_clock = None
    for row in rows:
        clock = int(row["clock"])
        if previous_clock is not None and clock < previous_clock:
            epoch += 1
        previous_clock = clock
        if row["age"] <= pulse_age or clock % 20:
            continue
        # Clock advances by 5 per game tick, i.e. 10 per redstone tick.
        # Original phase expression: floor(mod(redstone_time + 4, 6) / 2).
        phase = ((clock + 40) % 60) // 20
        cycle = (clock + 40) // 60
        raw = [int(v) for v in row["regs"]["A"]]
        if len(raw) != 13 or any(v < 0 or v > 15 for v in raw):
            raise ValueError("Invalid signal-strength data")
        direct = sum((v - 1) * 10**i for i, v in enumerate(raw))
        clamped = sum(max(0, v - 1) * 10**i for i, v in enumerate(raw))
        scores = row["scores"]
        legacy = (int(scores["Au"]) - 1800000000) * 10**7 + int(scores["Al"]) - 1700000000
        sample = {"age": int(row["age"]), "clock": clock,
                  "redstone_ticks": clock // 10, "clock_epoch": epoch, "cycle": cycle,
                  "phase": phase, "register": ("theta", "sin", "cos")[phase],
                  "raw_decoded": direct, "chat_decoded": clamped,
                  "scoreboard_decoded": legacy,
                  "legacy_matches_raw": legacy == direct,
                  "sign_probe": int(row["sign"])}
        samples.append(sample)
        cycles.setdefault((epoch, cycle), {})[phase] = sample
    complete = sorted(((i, s) for i, s in cycles.items() if len(s) == 3),
                      key=lambda entry: max(s["age"] for s in entry[1].values()))
    if not complete:
        raise ValueError("No complete three-phase cycle")
    (final_epoch, index), final = complete[-1]
    if final_epoch != epoch:
        raise ValueError("No complete cycle after the last clock reset")
    if not all(s["legacy_matches_raw"] for s in final.values()):
        raise ValueError("Legacy telemetry and direct samples disagree at endpoint")
    if not all(s["raw_decoded"] == s["chat_decoded"] for s in final.values()):
        raise ValueError("Digit offset decoding disagrees at endpoint")
    sin, cos = final[1]["scoreboard_decoded"], final[2]["scoreboard_decoded"]
    latest = {p: next(s for s in reversed(samples) if s["phase"] == p and s["clock_epoch"] == final_epoch)
              for p in (1, 2)}
    if latest[1]["scoreboard_decoded"] != sin or latest[2]["scoreboard_decoded"] != cos:
        raise ValueError("A later partial cycle changes the recovered output pair")
    stable = 0
    for (previous_epoch, _), previous in reversed(complete):
        if previous_epoch != final_epoch:
            break
        if (previous[1]["scoreboard_decoded"], previous[2]["scoreboard_decoded"]) != (sin, cos):
            break
        stable += 1
    input_sample = next((s for s in samples if s["clock"] == input_load_clock and s["phase"] == 0
                         and s["clock_epoch"] == final_epoch), None)
    result = {"kind": "Actual complete circuit log; last complete cycle before its freeze",
              "phase_source": "getVal2.m: floor(mod(T_rst+4,6)/2); T_rst=clock/10 from getLog.m",
              "period_redstone_ticks": 6, "period_game_ticks": 12,
              "clock_units_per_game_tick": 5,
              "terminal_age": int(rows[-1]["age"]),
              "terminal_clock": int(rows[-1]["clock"]),
              "final_clock_epoch": final_epoch, "final_cycle": index, "value_scale": 10**12,
              "sin_fixed": sin, "cos_fixed": cos,
              "sin": f"{sin/10**12:.12f}", "cos": f"{cos/10**12:.12f}",
              "stable_complete_cycles_at_endpoint": stable,
              "latest_sin_clock": latest[1]["clock"],
              "latest_cos_clock": latest[2]["clock"],
              "theta_channel_at_input_load": input_sample,
              "observed_input_degrees": input_sample["scoreboard_decoded"] / 10**11 if input_sample else None,
              "external_input_setting_location_identified": False,
              "endpoint_samples": [final[i] for i in range(3)],
              "complete_cycles": len(complete),
              "sample_count": len(samples)}
    return result, samples


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("trace", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--csv", type=Path, required=True)
    parser.add_argument("--input-load-clock", type=int,
                        help="Observed pre-rotation theta sample to report; does not affect phase decoding")
    args = parser.parse_args()
    rows = [json.loads(line) for line in args.trace.read_text().splitlines()]
    result, samples = decode(rows, args.input_load_clock)
    args.output.write_text(json.dumps(result, indent=2) + "\n")
    with args.csv.open("w") as stream:
        writer = csv.DictWriter(stream, fieldnames=list(samples[0]))
        writer.writeheader()
        writer.writerows(samples)
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
