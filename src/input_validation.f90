module input_validation
  use, intrinsic :: ieee_arithmetic, only: ieee_is_finite
  use kinds, only: dp
  use climate_types, only: weather_record, crop_window, exposure_config
  implicit none
  private
  public :: validate_and_sort_inputs

contains

  subroutine validate_and_sort_inputs(weather, windows, config, status, message)
    type(weather_record), intent(inout) :: weather(:)
    type(crop_window), intent(in) :: windows(:)
    type(exposure_config), intent(in) :: config
    integer, intent(out) :: status
    character(len=*), intent(out) :: message
    integer :: i, j
    status=0;message=""
    if(.not.ieee_is_finite(config%gdd_base_c).or..not.ieee_is_finite(config%gdd_cap_c).or. &
       .not.ieee_is_finite(config%edd_threshold_c).or..not.ieee_is_finite(config%hdd_threshold_c).or. &
       .not.ieee_is_finite(config%minimum_coverage))then;status=49;message="Configuration values must be finite";return;end if
    if(config%gdd_cap_c<=config%gdd_base_c)then;status=50;message="GDD cap must exceed base";return;end if
    if(config%minimum_coverage<0.0_dp.or.config%minimum_coverage>1.0_dp)then;status=51;message="Coverage must be in [0,1]";return;end if
    call quicksort_weather(weather,1,size(weather))
    if(size(weather)>0)then
      if(maxval(weather%location_key)>size(weather)+size(windows))then;status=56;message="location_key values must be compact positive integers";return;end if
    end if
    do i=2,size(weather)
      if(weather(i)%location_key==weather(i-1)%location_key.and.weather(i)%ordinal_date==weather(i-1)%ordinal_date)then
        status=52;write(message,'(A,A,A)')"Duplicate observation for ",trim(weather(i)%location_id)," on "//weather(i)%date;return
      end if
      if(weather(i)%location_key==weather(i-1)%location_key.and.trim(weather(i)%location_id)/=trim(weather(i-1)%location_id))then
        status=53;message="A location_key maps to multiple location_id values";return
      end if
    end do
    do i=1,size(windows)
      do j=i+1,size(windows)
        if(trim(windows(i)%season_id)==trim(windows(j)%season_id))then;status=54;message="Duplicate season_id";return;end if
      end do
    end do
    do i=1,size(windows)
      do j=1,size(weather)
        if(windows(i)%location_key==weather(j)%location_key)then
          if(trim(windows(i)%location_id)/=trim(weather(j)%location_id))then;status=55;message="Season and observation location_id disagree";return;end if
          exit
        end if
      end do
    end do
  end subroutine validate_and_sort_inputs

  recursive subroutine quicksort_weather(a,left,right)
    type(weather_record),intent(inout)::a(:)
    integer,intent(in)::left,right
    integer::i,j
    type(weather_record)::pivot,tmp
    if(left>=right)return
    pivot=a((left+right)/2);i=left;j=right
    do
      do while(less_than(a(i),pivot));i=i+1;end do
      do while(less_than(pivot,a(j)));j=j-1;end do
      if(i<=j)then;tmp=a(i);a(i)=a(j);a(j)=tmp;i=i+1;j=j-1;end if
      if(i>j)exit
    end do
    if(left<j)call quicksort_weather(a,left,j)
    if(i<right)call quicksort_weather(a,i,right)
  end subroutine quicksort_weather

  pure logical function less_than(a,b)
    type(weather_record),intent(in)::a,b
    less_than=a%location_key<b%location_key.or.(a%location_key==b%location_key.and.a%ordinal_date<b%ordinal_date)
  end function less_than
end module input_validation
