# Versioned data contracts

AgroClim-F v1 uses strict UTF-8 tab-separated text. Tabs and newlines are not
permitted inside fields. Headers must match exactly; malformed or extra fields
are rejected with the data-row number.

## observations-v1

```text
location_key location_id location_name date tmin_c tmax_c precip_mm
```

`location_key` is a compact positive integer computational key. `location_id` is the
stable research identifier. `date` is ISO `YYYY-MM-DD`. Temperatures are °C and
precipitation is mm/day.

## seasons-v1

```text
season_id location_key location_id season_name season_year start_date end_date
```

`season_id` must be globally unique. Dates are inclusive and may cross years.
`season_year` is an explicit label chosen by the analyst; it is never inferred.

## results-v1

Results retain all stable identifiers and interval dates, four exposure
measures, observed and expected day counts, coverage fraction, and QC status.
No zero-observation season is silently dropped.

## run-manifest-v1

The JSON manifest records software/schema versions, algorithm ID, paths, row
counts, parameters, thread count, compiler and options. The Python provenance
runner adds UTC time, platform, Git commit, and SHA-256 hashes for both inputs
and the result.
