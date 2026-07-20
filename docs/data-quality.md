# Data-quality policy

AgroClim-F rejects an input before computation when it finds:

- an unexpected schema header or field count;
- an empty identifier or location name;
- a non-positive computational location key;
- an invalid Gregorian date, including an invalid leap day;
- a non-finite temperature or precipitation value;
- `tmin_c > tmax_c`;
- negative precipitation;
- duplicate `(location_key, date)` observations;
- inconsistent mappings between `location_key` and `location_id`;
- duplicate `season_id` values; or
- a season whose end precedes its start.

For each valid season:

```text
coverage_fraction = observed_days / expected_days
```

Status is `PASS` when coverage meets `minimum_coverage`, `INCOMPLETE` when at
least one observation exists but coverage is lower, and `NO_DATA` otherwise.
Exposure totals are retained for audit, but downstream analyses should normally
exclude non-PASS rows or apply an explicitly documented missing-data policy.

The software does not impute, interpolate, or rescale incomplete seasons.
