#!/usr/bin/env python3
"""Repeated AgroClim kernel benchmark with median and dispersion reporting."""
from __future__ import annotations
import csv, platform, statistics, subprocess
from pathlib import Path

SIZES=(100_000,1_000_000,10_000_000); THREADS=(1,2,4,8); REPEATS=7
Path("results").mkdir(exist_ok=True)
rows=[]
for n in SIZES:
    for threads in THREADS:
        subprocess.run(["build/benchmark_kernel",str(n),str(threads)],capture_output=True,check=True,text=True)
        values=[];checksum=None
        for _ in range(REPEATS):
            fields=subprocess.check_output(["build/benchmark_kernel",str(n),str(threads)],text=True).splitlines()[-1].split(",")
            values.append(float(fields[2]));checksum=fields[4].strip()
        median=statistics.median(values);mad=statistics.median(abs(v-median) for v in values)
        rows.append({"observations":n,"threads":threads,"repetitions":REPEATS,"median_seconds":median,
                     "mad_seconds":mad,"million_obs_per_second":n/median/1e6,"checksum":checksum,
                     "platform":platform.platform(),"python":platform.python_version()})
with Path("results/benchmark_results.csv").open("w",newline="",encoding="utf-8") as handle:
    writer=csv.DictWriter(handle,fieldnames=rows[0]);writer.writeheader();writer.writerows(rows)
print("Wrote repeated benchmark results to results/benchmark_results.csv")
