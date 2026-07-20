# Changelog

All notable changes follow [Keep a Changelog](https://keepachangelog.com/) and
the project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.0.0] - 2026-07-20

### Added

- Explicit ISO-date season model and Gregorian leap-year handling.
- Strict observations-v1, seasons-v1, results-v1, and run-manifest-v1 contracts.
- Duplicate, identity, finite-value, precipitation, interval, and coverage QC.
- Stable location and season identifiers in every output.
- Indexed location aggregation and race-free season-level OpenMP parallelism.
- SHA-256 provenance runner and independent Python aggregation oracle.
- Offline NASA POWER Bangladesh validation case with committed raw checksums.
- Make, CMake/CTest, and Fortran Package Manager builds.
- Multi-platform CI, failure-mode tests, governance, and research documentation.

### Changed

- Reframed the project from a degree-day demonstration into citable research
  software for explicit crop-season exposure construction.
- Replaced fragile comma-to-space parsing and recurring DOY windows with strict
  tabular schemas and explicit dates.

### Removed

- Preliminary single-run performance claims from the prototype.

## [0.1.0] - 2026-07-20

- Initial Fortran/OpenMP prototype.
