#!/usr/bin/env python3
"""Transform committed NASA POWER JSON into AgroClim observations-v1 TSV."""
from __future__ import annotations
import csv, json
from pathlib import Path
from fetch_data import LOCATIONS

ROOT=Path(__file__).parent; RAW=ROOT/"data"/"raw"; PROCESSED=ROOT/"data"/"processed"
def main() -> None:
    PROCESSED.mkdir(parents=True,exist_ok=True);rows=[]
    for location_id,meta in LOCATIONS.items():
        payload=json.loads((RAW/f"{location_id.lower()}.json").read_text(encoding="utf-8"))
        parameters=payload["properties"]["parameter"]
        dates=sorted(parameters["T2M_MIN"])
        for stamp in dates:
            values=[parameters[name][stamp] for name in ("T2M_MIN","T2M_MAX","PRECTOTCORR")]
            if any(value == -999 for value in values): continue
            rows.append({"location_key":meta["key"],"location_id":location_id,"location_name":meta["name"],
                         "date":f"{stamp[:4]}-{stamp[4:6]}-{stamp[6:]}","tmin_c":values[0],
                         "tmax_c":values[1],"precip_mm":values[2]})
    out=PROCESSED/"observations.tsv"
    with out.open("w",newline="",encoding="utf-8") as handle:
        writer=csv.DictWriter(handle,fieldnames=rows[0],delimiter="\t",lineterminator="\n")
        writer.writeheader();writer.writerows(rows)
    print(f"Wrote {len(rows):,} observations to {out}")
if __name__=="__main__":main()
