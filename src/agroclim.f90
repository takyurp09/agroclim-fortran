module agroclim
  use kinds, only: dp
  use agroclim_version, only: version_string, schema_version
  use climate_types, only: weather_record, crop_window, exposure_config, exposure_result
  use degree_days, only: exceedance_degree_day, growing_degree_day, cold_degree_day
  use seasonal_aggregation, only: aggregate_exposures
  implicit none
  public
end module agroclim
