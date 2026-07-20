program test_degree_days
  use kinds, only: dp
  use degree_days, only: exceedance_degree_day, growing_degree_day, cold_degree_day
  implicit none
  integer :: failures
  failures = 0

  call assert_close("EDD below threshold", exceedance_degree_day(10.0_dp, 20.0_dp, 30.0_dp), 0.0_dp)
  call assert_close("EDD above threshold", exceedance_degree_day(30.0_dp, 40.0_dp, 20.0_dp), 15.0_dp)
  call assert_close("flat EDD", exceedance_degree_day(35.0_dp, 35.0_dp, 30.0_dp), 5.0_dp)
  call assert_close("capped GDD symmetry", growing_degree_day(0.0_dp, 40.0_dp, 10.0_dp, 30.0_dp), 10.0_dp)
  call assert_close("cold identity", cold_degree_day(0.0_dp, 20.0_dp, 10.0_dp), &
    10.0_dp - 10.0_dp + exceedance_degree_day(0.0_dp, 20.0_dp, 10.0_dp))
  call assert_true("GDD bounds", growing_degree_day(-5.0_dp, 45.0_dp, 8.0_dp, 30.0_dp) >= 0.0_dp .and. &
    growing_degree_day(-5.0_dp, 45.0_dp, 8.0_dp, 30.0_dp) <= 22.0_dp)
  call assert_true("EDD monotonicity", exceedance_degree_day(5.0_dp, 35.0_dp, 25.0_dp) >= &
    exceedance_degree_day(5.0_dp, 35.0_dp, 30.0_dp))

  if (failures > 0) then
    print '(I0,A)', failures, " test(s) failed."
    error stop 1
  end if
  print "(A)", "All degree-day tests passed."

contains
  subroutine assert_close(name, actual, expected)
    character(len=*), intent(in) :: name
    real(dp), intent(in) :: actual, expected
    if (abs(actual - expected) > 1.0e-11_dp) then
      print '(A,2(1X,ES16.8))', "FAIL: "//name, actual, expected
      failures = failures + 1
    end if
  end subroutine assert_close

  subroutine assert_true(name, condition)
    character(len=*), intent(in) :: name
    logical, intent(in) :: condition
    if (.not. condition) then
      print '(A)', "FAIL: "//name
      failures = failures + 1
    end if
  end subroutine assert_true
end program test_degree_days
