program test_calendar_dates
  use calendar_dates, only: is_leap_year, parse_iso_date, days_between
  implicit none
  integer :: a,b,failures
  logical :: ok
  failures=0
  call check(is_leap_year(2000),"2000 leap year")
  call check(.not.is_leap_year(1900),"1900 not leap year")
  call check(is_leap_year(2020),"2020 leap year")
  call parse_iso_date("2020-02-29",a,ok);call check(ok,"valid leap day")
  call parse_iso_date("2019-02-29",b,ok);call check(.not.ok,"invalid leap day")
  call parse_iso_date("2019-12-01",a,ok);call check(ok,"valid start")
  call parse_iso_date("2020-05-14",b,ok);call check(ok,"valid end")
  call check(days_between(a,b)==166,"cross-year inclusive interval")
  if(failures>0)error stop 1
  print '(A)',"All calendar tests passed."
contains
  subroutine check(condition,name)
    logical,intent(in)::condition;character(len=*),intent(in)::name
    if(.not.condition)then;print '(A)',"FAIL: "//name;failures=failures+1;end if
  end subroutine
end program
