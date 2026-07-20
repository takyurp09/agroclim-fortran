---
title: "AgroClim-F: Validated crop-season climate exposure calculations in modern Fortran"
tags:
  - Fortran
  - agricultural climate
  - degree days
  - crop calendars
authors:
  - name: Muhammad Taky Tahmid
    affiliation: 1
affiliations:
  - name: University of Delaware
    index: 1
date: 20 July 2026
bibliography: paper.bib
---

# Summary

AgroClim-F is an open-source Fortran library and command-line application for
constructing crop-season temperature and precipitation exposure measures from
daily weather records. It computes growing degree days, extreme degree days,
cold degree days, and precipitation totals over explicit location-specific
date intervals. The software preserves stable identifiers, reports temporal
coverage, rejects scientifically invalid inputs, and records parameters and
input/output hashes in a machine-readable run manifest.

# Statement of need

Climate–agriculture and climate-econometric studies repeatedly transform daily
minimum and maximum temperatures into nonlinear thermal exposure variables.
The transformation is simple enough to be reimplemented within individual
projects, but research pipelines can differ silently in threshold-crossing
formulas, leap-year behavior, growing-season endpoints, missing-day treatment,
and season-year labels. Such differences make results harder to audit and
replicate. AgroClim-F provides one tested computational boundary between daily
climate preprocessing and downstream statistical or process-based analysis.

# State of the field

Degree-day calculations are widely used in agricultural analysis following
sinusoidal approximations and nonlinear crop-temperature research
[@snyder1985; @schlenker2009]. General climate-data libraries provide strong
NetCDF, array, and spatial functionality, while crop models represent richer
biophysical mechanisms. AgroClim-F does not replace those systems. Its narrower
role is to provide a compiled, calendar-aware, provenance-producing exposure
engine that can be called after spatial preprocessing and before empirical or
model-data-fusion analysis.

# Software design

The numerical kernel evaluates closed-form sinusoidal exceedance integrals in
double precision. Capped growing degree days are expressed as the difference
between two exceedance integrals, avoiding fragile case-by-case formulas when a
daily temperature curve crosses both thresholds. An independent Python oracle
checks the closed form against high-resolution numerical quadrature.

Inputs use explicit ISO dates rather than inferred recurring day-of-year
windows. Gregorian leap years and inclusive endpoints determine the expected
number of days in each season. The validation layer rejects duplicate
location-date keys, invalid dates, non-finite values, negative precipitation,
inconsistent identifiers, and invalid season intervals. Every output reports
observed and expected days, coverage fraction, and one of `PASS`, `INCOMPLETE`,
or `NO_DATA`; the software does not silently impute or rescale missing days.

Observations are sorted once by integer location key and date. Seasons are
aggregated only over the contiguous observation block belonging to their
location, avoiding a global season-by-observation scan. Independent seasons are
parallelized with OpenMP without shared reductions, yielding deterministic
output ordering and values.

# Research impact statement

The repository includes an offline, checksummed NASA POWER case with 2,193
daily observations for three Bangladesh locations during 2019–2020. Nine
overlapping and cross-year illustrative seasons test leap-day handling and
multi-location execution. The compiled Fortran results reproduce an
independent Python aggregation within `1e-10 °C day`. The case is computational
validation, not agronomic calibration. AgroClim-F is intended for reuse in the
author's crop-yield, agricultural-labor, and climate-data evaluation pipelines
and for other studies that need an auditable seasonal exposure stage.

# AI usage disclosure

OpenAI Codex materially assisted architecture exploration, implementation,
tests, and documentation. Muhammad Taky Tahmid remains responsible for the
software and scientific claims. Assisted code is checked through compiler
runtime diagnostics, analytic-versus-quadrature tests, independent
cross-language aggregation, malformed-input tests, and reproducible real-data
regression outputs. The repository contains a permanent detailed disclosure.

# Acknowledgements

The validation dataset is provided by NASA's Prediction Of Worldwide Energy
Resources project [@nasa_power].

# References
