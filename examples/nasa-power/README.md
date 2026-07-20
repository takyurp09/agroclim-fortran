# NASA POWER Bangladesh validation case

This offline case study uses daily NASA POWER `T2M_MIN`, `T2M_MAX`, and
`PRECTOTCORR` point data for Dhaka, Khulna, and Rajshahi from 2019-01-01 through
2020-12-31. The interval deliberately includes the 2020 leap day.

The crop-season windows are illustrative computational windows, not calibrated
phenology recommendations. They demonstrate overlapping, cross-year, and
within-year intervals at multiple locations.

## Reproduce

```bash
python3 fetch_data.py
python3 transform.py
../../build/agroclim aggregate \
  --observations data/processed/observations.tsv \
  --seasons seasons.tsv --output results.tsv --manifest manifest.json
```

The committed `sha256.json` records the raw snapshot hashes. NASA POWER's Daily
Point API documentation is at <https://power.larc.nasa.gov/docs/services/api/temporal/>.
Users should consult NASA POWER documentation for parameter provenance, units,
spatial resolution, and terms of use before substantive analysis.
