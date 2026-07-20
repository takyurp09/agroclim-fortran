# Command-line reference

```text
agroclim aggregate \
  --observations observations.tsv \
  --seasons seasons.tsv \
  --output results.tsv \
  --manifest run-manifest.json \
  [--gdd-base 8] [--gdd-cap 30] \
  [--edd-threshold 30] [--hdd-threshold 10] \
  [--minimum-coverage 0.95] [--threads 1]
```

`--version` prints the software version; `--help` prints usage. Missing option
values, unknown options, invalid configuration, and invalid data return a
non-zero process status and a diagnostic beginning `agroclim: error:`.

For research runs, use `python/run_with_provenance.py`; it invokes the same CLI
and adds portable hashes and runtime metadata to the manifest.
