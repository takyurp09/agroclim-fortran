#!/usr/bin/env python3
"""Tolerance-aware comparison of two AgroClim results-v1 files."""
from __future__ import annotations
import argparse,csv
from pathlib import Path

NUMERIC=("gdd_c_day","edd_c_day","hdd_c_day","precip_mm","coverage_fraction")
def read(path:Path):
    with path.open(newline="",encoding="utf-8") as h:return {r["season_id"]:r for r in csv.DictReader(h,delimiter="\t")}
def main():
    p=argparse.ArgumentParser();p.add_argument("expected",type=Path);p.add_argument("actual",type=Path);p.add_argument("--tolerance",type=float,default=1e-9);a=p.parse_args()
    expected,actual=read(a.expected),read(a.actual);assert expected.keys()==actual.keys(),"season IDs differ"
    for key in expected:
        for field in NUMERIC:assert abs(float(expected[key][field])-float(actual[key][field]))<=a.tolerance,(key,field)
        for field in expected[key].keys()-set(NUMERIC):assert expected[key][field]==actual[key][field],(key,field)
    print(f"Regression results agree for {len(expected)} seasons within {a.tolerance:g}.")
if __name__=="__main__":main()
