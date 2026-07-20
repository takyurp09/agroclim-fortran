module climate_types
  use kinds, only: dp
  implicit none
  private
  public :: weather_record, crop_window, exposure_config, exposure_result

  integer, parameter :: id_len = 96, name_len = 160

  type :: weather_record
    integer :: location_key = 0
    character(len=id_len) :: location_id = ""
    character(len=name_len) :: location_name = ""
    character(len=10) :: date = ""
    integer :: ordinal_date = 0
    real(dp) :: tmin_c = 0.0_dp
    real(dp) :: tmax_c = 0.0_dp
    real(dp) :: precip_mm = 0.0_dp
  end type weather_record

  type :: crop_window
    character(len=id_len) :: season_id = ""
    integer :: location_key = 0
    character(len=id_len) :: location_id = ""
    character(len=name_len) :: season_name = ""
    integer :: season_year = 0
    character(len=10) :: start_date = ""
    character(len=10) :: end_date = ""
    integer :: start_ordinal = 0
    integer :: end_ordinal = 0
  end type crop_window

  type :: exposure_config
    real(dp) :: gdd_base_c = 8.0_dp
    real(dp) :: gdd_cap_c = 30.0_dp
    real(dp) :: edd_threshold_c = 30.0_dp
    real(dp) :: hdd_threshold_c = 10.0_dp
    real(dp) :: minimum_coverage = 0.95_dp
  end type exposure_config

  type :: exposure_result
    integer :: location_key = 0
    character(len=id_len) :: location_id = ""
    character(len=name_len) :: location_name = ""
    character(len=id_len) :: season_id = ""
    character(len=name_len) :: season_name = ""
    integer :: season_year = 0
    character(len=10) :: start_date = ""
    character(len=10) :: end_date = ""
    real(dp) :: gdd = 0.0_dp
    real(dp) :: edd = 0.0_dp
    real(dp) :: hdd = 0.0_dp
    real(dp) :: precip_mm = 0.0_dp
    integer :: observed_days = 0
    integer :: expected_days = 0
    real(dp) :: coverage_fraction = 0.0_dp
    character(len=24) :: qc_status = "NO_DATA"
  end type exposure_result

end module climate_types
