#!/usr/bin/env python3
"""Black-box failure-mode tests for the AgroClim-F command-line boundary."""
from __future__ import annotations
import subprocess, tempfile
from pathlib import Path

HEADER="location_key\tlocation_id\tlocation_name\tdate\ttmin_c\ttmax_c\tprecip_mm\n"
SEASONS="season_id\tlocation_key\tlocation_id\tseason_name\tseason_year\tstart_date\tend_date\nS1\t1\tLOC\tSeason\t2020\t2020-01-01\t2020-01-02\n"

def expect_failure(rows: str, expected: str) -> None:
    with tempfile.TemporaryDirectory() as tmp:
        root=Path(tmp);obs=root/"observations.tsv";seasons=root/"seasons.tsv"
        obs.write_text(HEADER+rows,encoding="utf-8");seasons.write_text(SEASONS,encoding="utf-8")
        result=subprocess.run(["build/agroclim","aggregate","--observations",str(obs),"--seasons",str(seasons),
            "--output",str(root/"out.tsv"),"--manifest",str(root/"manifest.json")],text=True,capture_output=True)
        assert result.returncode != 0, f"input unexpectedly succeeded: {rows!r}"
        assert expected in result.stdout+result.stderr, result.stdout+result.stderr

def main() -> None:
    expect_failure("1\tLOC\tPlace\t2019-02-29\t10\t20\t0\n","Invalid ISO date")
    expect_failure("1\tLOC\tPlace\t2020-01-01\t21\t20\t0\n","tmin_c exceeds tmax_c")
    expect_failure("1\tLOC\tPlace\t2020-01-01\t10\t20\t-1\n","Negative precipitation")
    expect_failure("1\tLOC\tPlace\t2020-01-01\t10\t20\t0\n1\tLOC\tPlace\t2020-01-01\t10\t20\t0\n","Duplicate observation")
    print("All CLI validation failure tests passed.")
if __name__=="__main__":main()
