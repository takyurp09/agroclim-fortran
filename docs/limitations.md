# Limitations and non-goals

- A sinusoid based on daily Tmin/Tmax is an approximation of sub-daily
  temperature, not a reconstruction of observed hourly conditions.
- Thresholds are user-supplied computational parameters. AgroClim-F does not
  claim that defaults are biologically calibrated for a crop or location.
- The software calculates exposure; it does not predict phenology, crop growth,
  yield, soil carbon, water balance, or nutrient cycling.
- Spatial extraction, regridding, harvested-area weighting, and crop-calendar
  estimation belong upstream of the v1 library.
- TSV prioritizes transparent archival interchange. Large gridded NetCDF/Zarr
  ingestion and MPI are post-v1 work.
- Parallel speed depends on the number and size of explicit seasons. The code
  does not claim universal speedup.
- NASA POWER point data in the example are a reproducibility case, not a
  validation of local station climate or crop response.
