# Data contract

## Daily weather

```csv
location_id,location_name,year,doy,tmin_c,tmax_c,precip_mm
BGD.1,Bagerhat,2020,1,12.0,25.0,0.0
```

- Temperatures are degrees Celsius.
- Precipitation is millimeters per day.
- `doy` is in `[1, 366]`.
- Location identifiers and names cannot contain commas or whitespace in v0.1.
- The MVP rejects rows where `tmin_c > tmax_c`.

## Crop windows

```csv
location_id,season,start_doy,end_doy
BGD.1,Boro,335,135
```

When `start_doy > end_doy`, the season crosses the year boundary. Output year
is the harvest year: day 335 of 2019 through day 135 of 2020 is labeled 2020.
Both endpoints are inclusive.

## Output

```csv
year,District,growing_season,gdd,edd,hdd,precip,valid_days
2020,Bagerhat,Boro,80.925071,2.574929,0.085227,15.000000,6
```

`valid_days` makes incomplete weather coverage visible. The engine does not
silently interpolate missing days.
