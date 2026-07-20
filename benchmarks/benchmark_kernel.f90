program benchmark_kernel
  use kinds, only: dp
  use degree_days, only: growing_degree_day, exceedance_degree_day, cold_degree_day
  use omp_lib, only: omp_get_wtime, omp_set_num_threads
  implicit none
  integer :: n, threads, i, ios
  real(dp), allocatable :: tmin(:), tmax(:)
  real(dp) :: started, elapsed, checksum
  character(len=64) :: arg

  n = 10000000
  threads = 1
  if (command_argument_count() >= 1) then
    call get_command_argument(1, arg); read(arg, *, iostat=ios) n
    if (ios /= 0 .or. n < 1) error stop "Invalid observation count"
  end if
  if (command_argument_count() >= 2) then
    call get_command_argument(2, arg); read(arg, *, iostat=ios) threads
    if (ios /= 0 .or. threads < 1) error stop "Invalid thread count"
  end if

  allocate(tmin(n), tmax(n))
  do i = 1, n
    tmin(i) = -5.0_dp + 30.0_dp * real(modulo(i * 37, 1000), dp) / 1000.0_dp
    tmax(i) = tmin(i) + 5.0_dp + 20.0_dp * real(modulo(i * 53, 1000), dp) / 1000.0_dp
  end do

  call omp_set_num_threads(threads)
  checksum = 0.0_dp
  started = omp_get_wtime()
  !$omp parallel do default(shared) private(i) reduction(+:checksum) schedule(static)
  do i = 1, n
    checksum = checksum + growing_degree_day(tmin(i), tmax(i), 8.0_dp, 30.0_dp) + &
      exceedance_degree_day(tmin(i), tmax(i), 30.0_dp) + &
      cold_degree_day(tmin(i), tmax(i), 10.0_dp)
  end do
  !$omp end parallel do
  elapsed = omp_get_wtime() - started

  print '(A)', "observations,threads,seconds,million_obs_per_second,checksum"
  print '(I0,",",I0,",",F0.6,",",F0.3,",",ES16.8)', n, threads, elapsed, &
    real(n, dp) / elapsed / 1.0e6_dp, checksum
end program benchmark_kernel
