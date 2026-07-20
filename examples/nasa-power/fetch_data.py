#!/usr/bin/env python3
"""Fetch the immutable AgroClim-F NASA POWER validation snapshot."""
from __future__ import annotations
import hashlib, json, urllib.parse, urllib.request
from pathlib import Path

LOCATIONS = {
    "BGD-DHAKA": {"key": 1, "name": "Dhaka", "latitude": 23.8103, "longitude": 90.4125},
    "BGD-KHULNA": {"key": 2, "name": "Khulna", "latitude": 22.8456, "longitude": 89.5403},
    "BGD-RAJSHAHI": {"key": 3, "name": "Rajshahi", "latitude": 24.3745, "longitude": 88.6042},
}
BASE = "https://power.larc.nasa.gov/api/temporal/daily/point"
RAW = Path(__file__).parent / "data" / "raw"

def main() -> None:
    RAW.mkdir(parents=True, exist_ok=True)
    checksums = {}
    for location_id, metadata in LOCATIONS.items():
        query = urllib.parse.urlencode({
            "parameters": "T2M_MIN,T2M_MAX,PRECTOTCORR", "community": "AG",
            "longitude": metadata["longitude"], "latitude": metadata["latitude"],
            "start": "20190101", "end": "20201231", "format": "JSON",
        })
        request = urllib.request.Request(f"{BASE}?{query}", headers={"User-Agent": "AgroClim-F/1.0"})
        with urllib.request.urlopen(request, timeout=120) as response:
            payload = response.read()
        path = RAW / f"{location_id.lower()}.json"
        path.write_bytes(payload)
        checksums[path.name] = hashlib.sha256(payload).hexdigest()
        print(f"Fetched {location_id}: {len(payload):,} bytes")
    (RAW / "sha256.json").write_text(json.dumps(checksums, indent=2, sort_keys=True)+"\n",encoding="utf-8")

if __name__ == "__main__": main()
