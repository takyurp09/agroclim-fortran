# Scientific methods

## Daily temperature approximation

For daily minimum temperature `Tmin` and maximum temperature `Tmax`, AgroClim-F
approximates the within-day temperature curve by

```text
T(θ) = M + W sin(θ),  θ ∈ [0, 2π]
M = (Tmin + Tmax) / 2
W = (Tmax - Tmin) / 2.
```

The exceedance degree day at threshold `a` is the daily mean integral of
`max(T(θ) - a, 0)`. The code evaluates the closed-form integral and handles the
entirely-below, entirely-above, and zero-range cases explicitly.

## Metrics

- `EDD(a)` integrates temperature above `a`.
- `GDD(base, cap) = EDD(base) - EDD(cap)`.
- `HDD(a) = a - M + EDD(a)` integrates temperature below `a`.
- Seasonal precipitation is the sum of valid daily precipitation.

Units are degree Celsius days (`°C day`) for thermal metrics and millimeters
(`mm`) for precipitation. Both endpoints of a season are included.

## Numerical verification

The Python oracle numerically integrates the sinusoidal curve at high
resolution and is structurally independent of the Fortran closed form. Seeded
random cases, exact threshold boundaries, flat days, negative temperatures,
and days spanning both GDD thresholds are tested. Seasonal outputs are also
reconstructed independently from the input records.

## References

- Snyder, R. L. (1985). Hand calculating degree days. *Agricultural and Forest
  Meteorology*, 35, 353–358.
- Schlenker, W., and Roberts, M. J. (2009). Nonlinear temperature effects
  indicate severe damages to U.S. crop yields under climate change.
  *Proceedings of the National Academy of Sciences*, 106(37), 15594–15598.
