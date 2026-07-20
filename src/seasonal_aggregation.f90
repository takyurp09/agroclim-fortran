module seasonal_aggregation
  use kinds, only: dp
  use climate_types, only: weather_record, crop_window, exposure_result
  use degree_days, only: growing_degree_day, exceedance_degree_day, cold_degree_day
  implicit none
  private
  public :: aggregate_exposures

contains

  pure logical function belongs_to_season(rec, window, harvest_year)
    type(weather_record), intent(in) :: rec
    type(crop_window), intent(in) :: window
    integer, intent(in) :: harvest_year

    if (window%start_doy <= window%end_doy) then
      belongs_to_season = rec%year == harvest_year .and. &
        rec%doy >= window%start_doy .and. rec%doy <= window%end_doy
    else
      belongs_to_season = (rec%year == harvest_year - 1 .and. rec%doy >= window%start_doy) .or. &
                          (rec%year == harvest_year .and. rec%doy <= window%end_doy)
    end if
  end function belongs_to_season

  subroutine aggregate_exposures(weather, windows, gdd_base, gdd_cap, edd_threshold, &
                                 hdd_threshold, results)
    type(weather_record), intent(in) :: weather(:)
    type(crop_window), intent(in) :: windows(:)
    real(dp), intent(in) :: gdd_base, gdd_cap, edd_threshold, hdd_threshold
    type(exposure_result), allocatable, intent(out) :: results(:)
    integer :: min_year, max_year, n_years, idx, w, y, i

    if (size(weather) == 0 .or. size(windows) == 0) then
      allocate(results(0))
      return
    end if
    min_year = minval(weather%year)
    max_year = maxval(weather%year)
    n_years = max_year - min_year + 2
    allocate(results(size(windows) * n_years))

    !$omp parallel do default(shared) private(idx,w,y,i) schedule(static)
    do idx = 1, size(results)
      w = (idx - 1) / n_years + 1
      y = min_year + modulo(idx - 1, n_years)
      results(idx)%year = y
      results(idx)%season = windows(w)%season
      do i = 1, size(weather)
        if (trim(weather(i)%location_id) /= trim(windows(w)%location_id)) cycle
        if (.not. belongs_to_season(weather(i), windows(w), y)) cycle
        results(idx)%location_name = weather(i)%location_name
        results(idx)%gdd = results(idx)%gdd + growing_degree_day( &
          weather(i)%tmin_c, weather(i)%tmax_c, gdd_base, gdd_cap)
        results(idx)%edd = results(idx)%edd + exceedance_degree_day( &
          weather(i)%tmin_c, weather(i)%tmax_c, edd_threshold)
        results(idx)%hdd = results(idx)%hdd + cold_degree_day( &
          weather(i)%tmin_c, weather(i)%tmax_c, hdd_threshold)
        results(idx)%precip_mm = results(idx)%precip_mm + weather(i)%precip_mm
        results(idx)%valid_days = results(idx)%valid_days + 1
      end do
    end do
    !$omp end parallel do
  end subroutine aggregate_exposures

end module seasonal_aggregation
