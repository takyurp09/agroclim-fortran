module degree_days
  use kinds, only: dp
  implicit none
  private
  public :: exceedance_degree_day, growing_degree_day, cold_degree_day

contains

  pure elemental function exceedance_degree_day(tmin, tmax, threshold) result(value)
    real(dp), intent(in) :: tmin, tmax, threshold
    real(dp) :: value
    real(dp) :: mean_temp, half_range, ratio, theta

    if (tmin > tmax) then
      value = -huge(1.0_dp)
      return
    end if

    mean_temp = 0.5_dp * (tmin + tmax)
    half_range = 0.5_dp * (tmax - tmin)

    if (half_range <= epsilon(1.0_dp)) then
      value = max(mean_temp - threshold, 0.0_dp)
    else if (threshold >= tmax) then
      value = 0.0_dp
    else if (threshold <= tmin) then
      value = mean_temp - threshold
    else
      ratio = max(-1.0_dp, min(1.0_dp, (threshold - mean_temp) / half_range))
      theta = acos(ratio)
      value = (half_range * sin(theta) + (mean_temp - threshold) * theta) / acos(-1.0_dp)
      value = max(value, 0.0_dp)
    end if
  end function exceedance_degree_day

  pure elemental function growing_degree_day(tmin, tmax, base, cap) result(value)
    real(dp), intent(in) :: tmin, tmax, base, cap
    real(dp) :: value

    if (cap <= base .or. tmin > tmax) then
      value = -huge(1.0_dp)
      return
    end if

    value = exceedance_degree_day(tmin, tmax, base) - &
            exceedance_degree_day(tmin, tmax, cap)
    value = max(0.0_dp, min(cap - base, value))
  end function growing_degree_day

  pure elemental function cold_degree_day(tmin, tmax, threshold) result(value)
    real(dp), intent(in) :: tmin, tmax, threshold
    real(dp) :: value, mean_temp

    if (tmin > tmax) then
      value = -huge(1.0_dp)
      return
    end if

    mean_temp = 0.5_dp * (tmin + tmax)
    value = threshold - mean_temp + exceedance_degree_day(tmin, tmax, threshold)
    value = max(value, 0.0_dp)
  end function cold_degree_day

end module degree_days
