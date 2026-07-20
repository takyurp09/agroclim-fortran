# Fortran library API

Downstream Fortran code should import the façade module:

```fortran
use agroclim, only: dp, exposure_config, weather_record, crop_window, &
  exposure_result, growing_degree_day, aggregate_exposures
```

Public numerical functions are pure and elemental:

```fortran
value = growing_degree_day(tmin, tmax, base, cap)
value = exceedance_degree_day(tmin, tmax, threshold)
value = cold_degree_day(tmin, tmax, threshold)
```

The array API accepts validated observations and explicit season intervals:

```fortran
call aggregate_exposures(observations, seasons, config, results)
```

I/O and validation are separate boundary modules. Library callers are expected
to validate data before aggregation; the CLI always does so. Public types and
schemas follow semantic versioning beginning with v1.0.
