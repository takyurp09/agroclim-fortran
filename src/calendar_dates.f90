module calendar_dates
  implicit none
  private
  public :: is_leap_year, days_in_year, valid_year_doy, parse_iso_date, days_between

contains

  pure elemental logical function is_leap_year(year)
    integer, intent(in) :: year
    is_leap_year = modulo(year, 400) == 0 .or. &
      (modulo(year, 4) == 0 .and. modulo(year, 100) /= 0)
  end function is_leap_year

  pure elemental integer function days_in_year(year)
    integer, intent(in) :: year
    days_in_year = merge(366, 365, is_leap_year(year))
  end function days_in_year

  pure elemental logical function valid_year_doy(year, doy)
    integer, intent(in) :: year, doy
    valid_year_doy = year >= 1 .and. doy >= 1 .and. doy <= days_in_year(year)
  end function valid_year_doy

  subroutine parse_iso_date(text, ordinal, ok)
    character(len=*), intent(in) :: text
    integer, intent(out) :: ordinal
    logical, intent(out) :: ok
    integer :: year, month, day, ios
    integer, parameter :: month_days(12) = [31,28,31,30,31,30,31,31,30,31,30,31]
    integer :: mdays

    ordinal = 0; ok = .false.
    if (len_trim(text) /= 10) return
    if (text(5:5) /= "-" .or. text(8:8) /= "-") return
    read(text(1:4), *, iostat=ios) year; if (ios /= 0) return
    read(text(6:7), *, iostat=ios) month; if (ios /= 0) return
    read(text(9:10), *, iostat=ios) day; if (ios /= 0) return
    if (year < 1 .or. month < 1 .or. month > 12) return
    mdays = month_days(month)
    if (month == 2 .and. is_leap_year(year)) mdays = 29
    if (day < 1 .or. day > mdays) return
    ordinal = 365 * (year - 1) + (year - 1) / 4 - (year - 1) / 100 + (year - 1) / 400
    ordinal = ordinal + sum(month_days(1:month-1)) + day
    if (month > 2 .and. is_leap_year(year)) ordinal = ordinal + 1
    ok = .true.
  end subroutine parse_iso_date

  pure integer function days_between(start_ordinal, end_ordinal)
    integer, intent(in) :: start_ordinal, end_ordinal
    days_between = end_ordinal - start_ordinal + 1
  end function days_between

end module calendar_dates
