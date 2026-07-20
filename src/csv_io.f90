module csv_io
  use kinds, only: dp
  use climate_types, only: weather_record, crop_window, exposure_result
  implicit none
  private
  public :: read_weather_csv, read_windows_csv, write_results_csv

contains

  subroutine commas_to_spaces(line)
    character(len=*), intent(inout) :: line
    integer :: i
    do i = 1, len_trim(line)
      if (line(i:i) == ",") line(i:i) = " "
    end do
  end subroutine commas_to_spaces

  subroutine read_weather_csv(path, records)
    character(len=*), intent(in) :: path
    type(weather_record), allocatable, intent(out) :: records(:)
    character(len=1024) :: line
    integer :: unit, ios, n, i

    open(newunit=unit, file=path, status="old", action="read", iostat=ios)
    if (ios /= 0) error stop "Cannot open daily weather CSV"
    read(unit, "(A)", iostat=ios) line
    n = 0
    do
      read(unit, "(A)", iostat=ios) line
      if (ios /= 0) exit
      if (len_trim(line) > 0) n = n + 1
    end do
    rewind(unit)
    read(unit, "(A)") line
    allocate(records(n))
    i = 0
    do
      read(unit, "(A)", iostat=ios) line
      if (ios /= 0) exit
      if (len_trim(line) == 0) cycle
      call commas_to_spaces(line)
      i = i + 1
      read(line, *, iostat=ios) records(i)%location_id, records(i)%location_name, &
        records(i)%year, records(i)%doy, records(i)%tmin_c, records(i)%tmax_c, &
        records(i)%precip_mm
      if (ios /= 0) error stop "Malformed daily weather CSV row"
      if (records(i)%doy < 1 .or. records(i)%doy > 366) error stop "Invalid day of year"
      if (records(i)%tmin_c > records(i)%tmax_c) error stop "tmin exceeds tmax"
    end do
    close(unit)
  end subroutine read_weather_csv

  subroutine read_windows_csv(path, windows)
    character(len=*), intent(in) :: path
    type(crop_window), allocatable, intent(out) :: windows(:)
    character(len=1024) :: line
    integer :: unit, ios, n, i

    open(newunit=unit, file=path, status="old", action="read", iostat=ios)
    if (ios /= 0) error stop "Cannot open crop windows CSV"
    read(unit, "(A)", iostat=ios) line
    n = 0
    do
      read(unit, "(A)", iostat=ios) line
      if (ios /= 0) exit
      if (len_trim(line) > 0) n = n + 1
    end do
    rewind(unit)
    read(unit, "(A)") line
    allocate(windows(n))
    i = 0
    do
      read(unit, "(A)", iostat=ios) line
      if (ios /= 0) exit
      if (len_trim(line) == 0) cycle
      call commas_to_spaces(line)
      i = i + 1
      read(line, *, iostat=ios) windows(i)%location_id, windows(i)%season, &
        windows(i)%start_doy, windows(i)%end_doy
      if (ios /= 0) error stop "Malformed crop windows CSV row"
      if (windows(i)%start_doy < 1 .or. windows(i)%start_doy > 366 .or. &
          windows(i)%end_doy < 1 .or. windows(i)%end_doy > 366) &
        error stop "Invalid crop-window day of year"
    end do
    close(unit)
  end subroutine read_windows_csv

  subroutine write_results_csv(path, results)
    character(len=*), intent(in) :: path
    type(exposure_result), intent(in) :: results(:)
    integer :: unit, ios, i

    open(newunit=unit, file=path, status="replace", action="write", iostat=ios)
    if (ios /= 0) error stop "Cannot create output CSV"
    write(unit, "(A)") "year,District,growing_season,gdd,edd,hdd,precip,valid_days"
    do i = 1, size(results)
      if (results(i)%valid_days == 0) cycle
      write(unit, '(I0,",",A,",",A,",",F0.6,",",F0.6,",",F0.6,",",F0.6,",",I0)') &
        results(i)%year, trim(results(i)%location_name), trim(results(i)%season), &
        results(i)%gdd, results(i)%edd, results(i)%hdd, results(i)%precip_mm, &
        results(i)%valid_days
    end do
    close(unit)
  end subroutine write_results_csv

end module csv_io
