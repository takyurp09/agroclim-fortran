#!/usr/bin/env python3
"""Run AgroClim-F and augment its manifest with portable SHA-256 provenance."""

from __future__ import annotations

import argparse
import hashlib
import json
import platform
import subprocess
from datetime import datetime, timezone
from pathlib import Path


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--executable", type=Path, default=Path("build/agroclim"))
    parser.add_argument("--observations", type=Path, required=True)
    parser.add_argument("--seasons", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--threads", type=int, default=1)
    parser.add_argument("--minimum-coverage", type=float, default=0.95)
    args = parser.parse_args()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    command = [str(args.executable), "aggregate", "--observations", str(args.observations),
               "--seasons", str(args.seasons), "--output", str(args.output),
               "--manifest", str(args.manifest), "--threads", str(args.threads),
               "--minimum-coverage", str(args.minimum_coverage)]
    subprocess.run(command, check=True)
    manifest = json.loads(args.manifest.read_text(encoding="utf-8"))
    manifest["created_utc"] = datetime.now(timezone.utc).isoformat()
    manifest["sha256"] = {
        "observations": sha256(args.observations),
        "seasons": sha256(args.seasons),
        "results": sha256(args.output),
    }
    manifest["runtime"] = {"platform": platform.platform(), "python": platform.python_version()}
    try:
        manifest["git_commit"] = subprocess.check_output(
            ["git", "rev-parse", "HEAD"], text=True, stderr=subprocess.DEVNULL
        ).strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        manifest["git_commit"] = None
    args.manifest.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"Wrote provenance manifest: {args.manifest}")


if __name__ == "__main__":
    main()
