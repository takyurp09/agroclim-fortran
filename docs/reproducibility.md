# Reproducibility

1. Record the tagged AgroClim-F version or archived DOI.
2. Preserve observations and seasons files without modification.
3. Run through `python/run_with_provenance.py`.
4. Archive the result and JSON manifest together.
5. Verify the SHA-256 hashes before analysis.

`make test` exercises numerical identities, quadrature agreement, Gregorian
calendar behavior, malformed-input rejection, independent seasonal parity, and
thread determinism. GitHub Actions repeats the suite with Make, CMake, and fpm
on Linux and macOS, and rebuilds the committed NASA POWER case offline.

Raw NASA POWER snapshots can be refreshed with the included fetcher, but a
provider may revise historical data. Exact reproduction should use the
committed checksummed snapshot associated with a tagged software release.
