#!/usr/bin/env python3
"""Independent seasonal aggregation used to verify the compiled Fortran CLI."""

from __future__ import annotations

import argparse
import csv
from datetime import date
from pathlib import Path

from reference_indices import edd, gdd, hdd


def read_tsv(path: Path) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle, delimiter="\t"))


def expected_rows(observations: Path, seasons: Path) -> dict[str, dict[str, float]]:
    daily = read_tsv(observations)
    output: dict[str, dict[str, float]] = {}
    for season in read_tsv(seasons):
        start = date.fromisoformat(season["start_date"])
        end = date.fromisoformat(season["end_date"])
        expected_days = (end - start).days + 1
        result = {"gdd_c_day": 0.0, "edd_c_day": 0.0, "hdd_c_day": 0.0,
                  "precip_mm": 0.0, "observed_days": 0.0,
                  "expected_days": float(expected_days)}
        for row in daily:
            current = date.fromisoformat(row["date"])
            if row["location_key"] != season["location_key"] or not start <= current <= end:
                continue
            tmin, tmax = float(row["tmin_c"]), float(row["tmax_c"])
            result["gdd_c_day"] += gdd(tmin, tmax, 8.0, 30.0)
            result["edd_c_day"] += edd(tmin, tmax, 30.0)
            result["hdd_c_day"] += hdd(tmin, tmax, 10.0)
            result["precip_mm"] += float(row["precip_mm"])
            result["observed_days"] += 1
        output[season["season_id"]] = result
    return output


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--observations", type=Path, required=True)
    parser.add_argument("--seasons", type=Path, required=True)
    parser.add_argument("--fortran-output", type=Path, required=True)
    args = parser.parse_args()
    expected = expected_rows(args.observations, args.seasons)
    actual = read_tsv(args.fortran_output)
    if len(actual) != len(expected):
        raise SystemExit(f"row-count mismatch: Fortran={len(actual)}, Python={len(expected)}")
    for row in actual:
        target = expected[row["season_id"]]
        for field in ("gdd_c_day", "edd_c_day", "hdd_c_day", "precip_mm"):
            difference = abs(float(row[field]) - target[field])
            if difference > 1.0e-10:
                raise SystemExit(f"{row['season_id']} {field} mismatch: {difference:.3e}")
        for field in ("observed_days", "expected_days"):
            if int(row[field]) != int(target[field]):
                raise SystemExit(f"{row['season_id']} {field} mismatch")
    print(f"Independent Python–Fortran parity passed for {len(actual)} seasons.")


if __name__ == "__main__":
    main()
