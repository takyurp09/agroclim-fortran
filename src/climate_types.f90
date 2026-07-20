module climate_types
  use kinds, only: dp
  implicit none
  private
  public :: weather_record, crop_window, exposure_result

  integer, parameter :: text_len = 96

  type :: weather_record
    character(len=text_len) :: location_id = ""
    character(len=text_len) :: location_name = ""
    integer :: year = 0
    integer :: doy = 0
    real(dp) :: tmin_c = 0.0_dp
    real(dp) :: tmax_c = 0.0_dp
    real(dp) :: precip_mm = 0.0_dp
  end type weather_record

  type :: crop_window
    character(len=text_len) :: location_id = ""
    character(len=text_len) :: season = ""
    integer :: start_doy = 0
    integer :: end_doy = 0
  end type crop_window

  type :: exposure_result
    integer :: year = 0
    character(len=text_len) :: location_name = ""
    character(len=text_len) :: season = ""
    real(dp) :: gdd = 0.0_dp
    real(dp) :: edd = 0.0_dp
    real(dp) :: hdd = 0.0_dp
    real(dp) :: precip_mm = 0.0_dp
    integer :: valid_days = 0
  end type exposure_result

end module climate_types
