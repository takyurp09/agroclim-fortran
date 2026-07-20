module seasonal_aggregation
  use kinds, only: dp
  use climate_types, only: weather_record, crop_window, exposure_config, exposure_result
  use calendar_dates, only: days_between
  use degree_days, only: growing_degree_day, exceedance_degree_day, cold_degree_day
  implicit none
  private
  public :: aggregate_exposures

contains

  subroutine aggregate_exposures(weather, windows, config, results)
    type(weather_record), intent(in) :: weather(:)
    type(crop_window), intent(in) :: windows(:)
    type(exposure_config), intent(in) :: config
    type(exposure_result), allocatable, intent(out) :: results(:)
    integer, allocatable :: first_observation(:), last_observation(:)
    integer :: max_key, i, w

    if (size(windows) == 0) then
      allocate(results(0)); return
    end if
    max_key = max(1, maxval(windows%location_key))
    if (size(weather) > 0) max_key = max(max_key, maxval(weather%location_key))
    allocate(first_observation(max_key),last_observation(max_key))
    first_observation=0;last_observation=0
    do i=1,size(weather)
      if(first_observation(weather(i)%location_key)==0)first_observation(weather(i)%location_key)=i
      last_observation(weather(i)%location_key)=i
    end do

    allocate(results(size(windows)))
    do w = 1, size(windows)
      results(w)%location_key = windows(w)%location_key
      results(w)%location_id = windows(w)%location_id
      results(w)%season_id = windows(w)%season_id
      results(w)%season_name = windows(w)%season_name
      results(w)%season_year = windows(w)%season_year
      results(w)%start_date = windows(w)%start_date
      results(w)%end_date = windows(w)%end_date
      results(w)%expected_days = days_between(windows(w)%start_ordinal, windows(w)%end_ordinal)
    end do

    ! Independent season intervals are parallelized without reductions or races.
    !$omp parallel do default(shared) private(w,i) schedule(dynamic)
    do w = 1, size(windows)
      if(first_observation(windows(w)%location_key)>0)then
        do i=first_observation(windows(w)%location_key),last_observation(windows(w)%location_key)
          if (weather(i)%ordinal_date >= windows(w)%start_ordinal .and. &
              weather(i)%ordinal_date <= windows(w)%end_ordinal) then
          results(w)%location_name = weather(i)%location_name
          results(w)%gdd = results(w)%gdd + growing_degree_day( &
            weather(i)%tmin_c, weather(i)%tmax_c, config%gdd_base_c, config%gdd_cap_c)
          results(w)%edd = results(w)%edd + exceedance_degree_day( &
            weather(i)%tmin_c, weather(i)%tmax_c, config%edd_threshold_c)
          results(w)%hdd = results(w)%hdd + cold_degree_day( &
            weather(i)%tmin_c, weather(i)%tmax_c, config%hdd_threshold_c)
          results(w)%precip_mm = results(w)%precip_mm + weather(i)%precip_mm
            results(w)%observed_days = results(w)%observed_days + 1
          end if
        end do
      end if
    end do
    !$omp end parallel do

    !$omp parallel do default(shared) private(i) schedule(static)
    do i = 1, size(results)
      if (results(i)%expected_days > 0) &
        results(i)%coverage_fraction = real(results(i)%observed_days, dp) / real(results(i)%expected_days, dp)
      if (results(i)%observed_days == 0) then
        results(i)%qc_status = "NO_DATA"
      else if (results(i)%coverage_fraction >= config%minimum_coverage) then
        results(i)%qc_status = "PASS"
      else
        results(i)%qc_status = "INCOMPLETE"
      end if
    end do
    !$omp end parallel do
  end subroutine aggregate_exposures

end module seasonal_aggregation
