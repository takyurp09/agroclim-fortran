program agroclim_cli
  use kinds, only: dp
  use climate_types, only: weather_record, crop_window, exposure_result
  use csv_io, only: read_weather_csv, read_windows_csv, write_results_csv
  use seasonal_aggregation, only: aggregate_exposures
  use omp_lib, only: omp_set_num_threads
  implicit none

  type(weather_record), allocatable :: weather(:)
  type(crop_window), allocatable :: windows(:)
  type(exposure_result), allocatable :: results(:)
  character(len=512) :: daily_path, windows_path, output_path, arg
  real(dp) :: gdd_base, gdd_cap, edd_threshold, hdd_threshold
  integer :: threads, i, ios

  daily_path = ""
  windows_path = ""
  output_path = ""
  gdd_base = 8.0_dp
  gdd_cap = 30.0_dp
  edd_threshold = 30.0_dp
  hdd_threshold = 10.0_dp
  threads = 1

  if (command_argument_count() == 0) then
    call print_help()
    stop
  end if

  i = 1
  do while (i <= command_argument_count())
    call get_command_argument(i, arg)
    select case (trim(arg))
    case ("--help", "-h")
      call print_help()
      stop
    case ("--version")
      print "(A)", "agroclim 0.1.0"
      stop
    case ("compute")
      ! Subcommand marker.
    case ("--daily")
      i = i + 1; call get_command_argument(i, daily_path)
    case ("--windows")
      i = i + 1; call get_command_argument(i, windows_path)
    case ("--output")
      i = i + 1; call get_command_argument(i, output_path)
    case ("--gdd-base")
      i = i + 1; call get_command_argument(i, arg); read(arg, *, iostat=ios) gdd_base
      if (ios /= 0) error stop "Invalid --gdd-base"
    case ("--gdd-cap")
      i = i + 1; call get_command_argument(i, arg); read(arg, *, iostat=ios) gdd_cap
      if (ios /= 0) error stop "Invalid --gdd-cap"
    case ("--edd-threshold")
      i = i + 1; call get_command_argument(i, arg); read(arg, *, iostat=ios) edd_threshold
      if (ios /= 0) error stop "Invalid --edd-threshold"
    case ("--hdd-threshold")
      i = i + 1; call get_command_argument(i, arg); read(arg, *, iostat=ios) hdd_threshold
      if (ios /= 0) error stop "Invalid --hdd-threshold"
    case ("--threads")
      i = i + 1; call get_command_argument(i, arg); read(arg, *, iostat=ios) threads
      if (ios /= 0 .or. threads < 1) error stop "Invalid --threads"
    case default
      error stop "Unknown command-line argument; run with --help"
    end select
    i = i + 1
  end do

  if (len_trim(daily_path) == 0 .or. len_trim(windows_path) == 0 .or. &
      len_trim(output_path) == 0) error stop "--daily, --windows, and --output are required"
  if (gdd_cap <= gdd_base) error stop "GDD cap must exceed GDD base"

  call omp_set_num_threads(threads)
  call read_weather_csv(trim(daily_path), weather)
  call read_windows_csv(trim(windows_path), windows)
  call aggregate_exposures(weather, windows, gdd_base, gdd_cap, edd_threshold, &
    hdd_threshold, results)
  call write_results_csv(trim(output_path), results)
  print '(A,I0,A,I0,A)', "Processed ", size(weather), " daily records using ", threads, " thread(s)."

contains

  subroutine print_help()
    print "(A)", "agroclim - Fortran/OpenMP crop-climate exposure engine"
    print "(A)", ""
    print "(A)", "Usage:"
    print "(A)", "  agroclim compute --daily FILE --windows FILE --output FILE [options]"
    print "(A)", ""
    print "(A)", "Options:"
    print "(A)", "  --gdd-base VALUE       Growing-degree-day base (default: 8)"
    print "(A)", "  --gdd-cap VALUE        Growing-degree-day cap (default: 30)"
    print "(A)", "  --edd-threshold VALUE  Extreme-heat threshold (default: 30)"
    print "(A)", "  --hdd-threshold VALUE  Cold-degree threshold (default: 10)"
    print "(A)", "  --threads N            OpenMP threads (default: 1)"
  end subroutine print_help

end program agroclim_cli
