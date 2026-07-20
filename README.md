# AgroClim Fortran

A modern Fortran/OpenMP engine for calculating crop-relevant temperature
exposure across location-specific growing seasons.

The project turns daily minimum temperature, maximum temperature, and
precipitation into seasonal growing degree days (GDD), extreme degree days
(EDD), cold degree days (HDD), and precipitation totals. It handles seasons
that cross calendar years and produces deterministic results with one or
multiple CPU threads.

## What this demonstrates

- Modern Fortran 2018 modules and pure elemental numerical functions
- Scientific formula validation against an independent quadrature oracle
- OpenMP parallel processing with deterministic seasonal outputs
- Linux-compatible command-line software and automated CI
- A Python-to-Fortran workflow for agricultural climate data

## Quick start

Requirements: GNU Fortran, GNU Make, and Python 3.

```bash
make test
```

This compiles the Fortran tests, checks the analytic equations against
numerical integration, runs the example with OpenMP, and confirms complete
Python–Fortran output parity.

Run the example directly:

```bash
make example
```

Or choose parameters:

```bash
build/agroclim compute \
  --daily examples/daily_weather.csv \
  --windows examples/crop_windows.csv \
  --output results/exposure.csv \
  --gdd-base 8 \
  --gdd-cap 30 \
  --edd-threshold 30 \
  --hdd-threshold 10 \
  --threads 4
```

## Scientific design

The engine integrates a sinusoidal approximation of within-day temperature.
Capped GDD is evaluated with the robust identity
`GDD(base, cap) = EDD(base) - EDD(cap)`. See
[`docs/numerical_method.md`](docs/numerical_method.md) for the equations and
validation design.

Python prepares flat daily weather records after any ERA5/CMIP6 and geospatial
processing. Fortran performs the repeated numerical calculations and
crop-calendar aggregation. See [`docs/data_contract.md`](docs/data_contract.md).

## Benchmarks

Compile and run the kernel benchmark:

```bash
make benchmark
```

The benchmark reports measured throughput for 100,000, 1 million, and
10 million synthetic daily observations with 1, 2, 4, and 8 OpenMP threads.
Performance depends on hardware; the repository does not claim a speedup until
measurements have been recorded. See the
[`preliminary local results`](docs/performance.md).

## Scope

AgroClim Fortran is a high-performance climate-exposure engine, not a
process-based crop or ecosystem model. NetCDF, raster, and polygon operations
remain in Python, where mature scientific libraries already handle them well.
See [`docs/limitations.md`](docs/limitations.md) and
[`docs/provenance.md`](docs/provenance.md).

## Author

Muhammad Taky Tahmid, University of Delaware

## License

MIT
