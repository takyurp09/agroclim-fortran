# Numerical method

## Daily temperature curve

The engine approximates temperature within a day as a sinusoid determined by
daily minimum and maximum temperatures:

```text
T(t) = M + W sin(t)
M = (Tmin + Tmax) / 2
W = (Tmax - Tmin) / 2
```

An exceedance degree day at threshold `a` is the daily mean of
`max(T(t) - a, 0)`. The implementation evaluates its closed-form integral.

Capped growing degree days use the identity:

```text
GDD(base, cap) = EDD(base) - EDD(cap)
```

This identity avoids fragile case-by-case expressions when the daily
temperature curve crosses both thresholds. Cold degree days use:

```text
HDD(a) = a - M + EDD(a)
```

All calculations use IEEE double precision.

## Validation

The analytic implementation is checked against an independent midpoint
quadrature of the sinusoidal temperature curve. Tests include flat days,
threshold crossings, temperatures below freezing, a day spanning both GDD
thresholds, and seeded random cases.

## References

- Snyder, R. L. (1985). Hand calculating degree days. *Agricultural and Forest
  Meteorology*, 35, 353–358.
- Schlenker, W., and Roberts, M. J. (2009). Nonlinear temperature effects
  indicate severe damages to U.S. crop yields under climate change.
  *Proceedings of the National Academy of Sciences*, 106(37), 15594–15598.
