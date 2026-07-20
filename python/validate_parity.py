#!/usr/bin/env python3
"""Validate Fortran seasonal output against the independent Python reference."""

from __future__ import annotations

import argparse
import csv
from collections import defaultdict
from pathlib import Path

from reference_indices import edd, gdd, hdd


def in_window(row: dict[str, str], window: dict[str, str], harvest_year: int) -> bool:
    year = int(row["year"])
    doy = int(row["doy"])
    start = int(window["start_doy"])
    end = int(window["end_doy"])
    if start <= end:
        return year == harvest_year and start <= doy <= end
    return (year == harvest_year - 1 and doy >= start) or (
        year == harvest_year and doy <= end
    )


def expected_rows(daily_path: Path, windows_path: Path) -> dict[tuple[int, str, str], dict[str, float]]:
    with daily_path.open(newline="", encoding="utf-8") as handle:
        daily = list(csv.DictReader(handle))
    with windows_path.open(newline="", encoding="utf-8") as handle:
        windows = list(csv.DictReader(handle))
    min_year = min(int(row["year"]) for row in daily)
    max_year = max(int(row["year"]) for row in daily)
    output: dict[tuple[int, str, str], dict[str, float]] = defaultdict(
        lambda: {"gdd": 0.0, "edd": 0.0, "hdd": 0.0, "precip": 0.0, "valid_days": 0.0}
    )
    for window in windows:
        for harvest_year in range(min_year, max_year + 2):
            for row in daily:
                if row["location_id"] != window["location_id"] or not in_window(row, window, harvest_year):
                    continue
                key = (harvest_year, row["location_name"], window["season"])
                tmin = float(row["tmin_c"])
                tmax = float(row["tmax_c"])
                output[key]["gdd"] += gdd(tmin, tmax, 8.0, 30.0)
                output[key]["edd"] += edd(tmin, tmax, 30.0)
                output[key]["hdd"] += hdd(tmin, tmax, 10.0)
                output[key]["precip"] += float(row["precip_mm"])
                output[key]["valid_days"] += 1
    return {key: value for key, value in output.items() if value["valid_days"]}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--daily", type=Path, required=True)
    parser.add_argument("--windows", type=Path, required=True)
    parser.add_argument("--fortran-output", type=Path, required=True)
    args = parser.parse_args()

    expected = expected_rows(args.daily, args.windows)
    with args.fortran_output.open(newline="", encoding="utf-8") as handle:
        actual_rows = list(csv.DictReader(handle))
    if len(actual_rows) != len(expected):
        raise SystemExit(f"row-count mismatch: Fortran={len(actual_rows)}, Python={len(expected)}")

    for row in actual_rows:
        key = (int(row["year"]), row["District"], row["growing_season"])
        if key not in expected:
            raise SystemExit(f"unexpected Fortran row: {key}")
        for field in ("gdd", "edd", "hdd", "precip"):
            difference = abs(float(row[field]) - expected[key][field])
            if difference > 5.1e-7:
                raise SystemExit(f"{key} {field} mismatch: {difference:.3e}")
        if int(row["valid_days"]) != int(expected[key]["valid_days"]):
            raise SystemExit(f"{key} valid_days mismatch")

    print(f"Python–Fortran parity passed for {len(actual_rows)} seasonal rows.")


if __name__ == "__main__":
    main()
