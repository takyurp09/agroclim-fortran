# Provenance

AgroClim Fortran was motivated by the author's Python climate-data pipelines
for agricultural exposure measurement. Those pipelines process ERA5 and CMIP6
temperature data, apply crop calendars, and aggregate exposure to agricultural
regions.

This repository is a new implementation. It ports the underlying published
degree-day method into modern Fortran, independently checks the formulas with
numerical integration, and adds deterministic OpenMP execution. Python remains
the appropriate layer for NetCDF, Zarr, raster, and vector preprocessing.

This project is a crop-climate exposure engine. It is not a process-based crop
growth, soil biogeochemistry, or ecosystem model.
