# AgroClim-F

[![Scientific validation](https://github.com/takyurp09/agroclim-fortran/actions/workflows/ci.yml/badge.svg)](https://github.com/takyurp09/agroclim-fortran/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Fortran 2018](https://img.shields.io/badge/Fortran-2018-734f96.svg)](https://fortran-lang.org/)

**Validated crop-season climate exposure calculations in modern Fortran.**

AgroClim-F converts daily minimum temperature, maximum temperature, and
precipitation into auditable crop-season exposure measures. It provides a
reusable Fortran library and command-line application with exact Gregorian
calendar semantics, explicit data-quality rules, deterministic OpenMP
parallelism, versioned tabular schemas, and a SHA-256 run manifest.

The software is designed for climate–agriculture and climate-econometric
pipelines. It is not a crop-growth, phenology, or yield-prediction model.

## Why it exists

Crop-climate studies repeatedly construct growing degree days (GDD), extreme
degree days (EDD), cold degree days (HDD), and precipitation totals over
location-specific seasons. Small differences in threshold formulas, leap-year
handling, missing observations, or season labeling can silently alter research
panels. AgroClim-F makes those choices explicit and machine-verifiable.

## Scientific guarantees

- Closed-form sinusoidal degree-day integrals in IEEE double precision
- Capped GDD computed by the stable identity `EDD(base) - EDD(cap)`
- Independent high-resolution quadrature verification
- Explicit ISO start and end dates with inclusive Gregorian intervals
- Duplicate, invalid-date, non-finite, negative-precipitation, and identity checks
- Observed days, expected days, coverage fraction, and QC status in every result
- Byte-identical output across tested OpenMP thread counts
- Input and output SHA-256 hashes in the provenance manifest

## Five-minute run

Requirements: GNU Fortran, GNU Make, and Python 3.

```bash
git clone https://github.com/takyurp09/agroclim-fortran.git
cd agroclim-fortran
make test
```

Run the compact example:

```bash
make example
column -t -s $'\t' results/exposures.tsv
```

The production-style command is:

```bash
python3 python/run_with_provenance.py \
  --executable build/agroclim \
  --observations observations.tsv \
  --seasons seasons.tsv \
  --output exposures.tsv \
  --manifest run-manifest.json \
  --threads 4
```

See [CLI reference](docs/cli.md) and [data contracts](docs/data-contract.md).

## Reproducible NASA POWER case study

The committed offline case contains 2,193 daily observations for Dhaka,
Khulna, and Rajshahi during 2019–2020 and nine illustrative seasons. It includes
the 2020 leap day and overlapping/cross-year intervals. Raw NASA POWER JSON,
SHA-256 checksums, transformation code, expected results, and an independent
Python calculation are included under [`examples/nasa-power`](examples/nasa-power/README.md).

All nine seasons have complete temporal coverage in the snapshot. Fortran and
the independent Python reference agree within `1e-10 °C day`.

## Installation

GNU Make:

```bash
make release
```

Fortran Package Manager:

```bash
fpm build --profile release
fpm test
```

CMake:

```bash
cmake -S . -B build-cmake -DCMAKE_BUILD_TYPE=Release
cmake --build build-cmake
ctest --test-dir build-cmake --output-on-failure
cmake --install build-cmake --prefix /desired/prefix
```

## Documentation

- [Scientific methods](docs/methods.md)
- [Data-quality policy](docs/data-quality.md)
- [Data contracts](docs/data-contract.md)
- [Library API](docs/api.md)
- [CLI reference](docs/cli.md)
- [Reproducibility](docs/reproducibility.md)
- [Limitations](docs/limitations.md)
- [Development and AI-assistance disclosure](docs/development-disclosure.md)

## Citation

Use GitHub's **Cite this repository** control, which reads [`CITATION.cff`](CITATION.cff).
For formal research use, cite a tagged, archived release rather than the moving
`main` branch. A Zenodo DOI will be added after the v1.0 release archive is
enabled by the repository owner.

## Contributing and support

See [CONTRIBUTING.md](CONTRIBUTING.md), [SUPPORT.md](SUPPORT.md), and
[SECURITY.md](SECURITY.md). Development follows semantic versioning and the
changes are recorded in [CHANGELOG.md](CHANGELOG.md).

## License

MIT © 2026 Muhammad Taky Tahmid.
