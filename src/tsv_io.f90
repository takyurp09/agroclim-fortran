module tsv_io
  use, intrinsic :: ieee_arithmetic, only: ieee_is_finite
  use kinds, only: dp
  use climate_types, only: weather_record, crop_window, exposure_result
  use calendar_dates, only: parse_iso_date
  implicit none
  private
  public :: read_weather_tsv, read_seasons_tsv, write_results_tsv

contains

  subroutine split_tsv(line, fields, nfields)
    character(len=*), intent(in) :: line
    character(len=*), intent(out) :: fields(:)
    integer, intent(out) :: nfields
    integer :: i, start, length
    fields = ""; nfields = 0; start = 1; length = len_trim(line)
    do i = 1, length + 1
      if (i > length .or. line(i:i) == achar(9)) then
        nfields = nfields + 1
        if (nfields <= size(fields) .and. i > start) fields(nfields) = line(start:i-1)
        start = i + 1
      end if
    end do
  end subroutine split_tsv

  subroutine fail(status, message, code, text, row)
    integer, intent(out) :: status
    character(len=*), intent(out) :: message
    integer, intent(in) :: code, row
    character(len=*), intent(in) :: text
    status = code
    write(message, '(A," at data row ",I0)') trim(text), row
  end subroutine fail

  subroutine read_weather_tsv(path, records, status, message)
    character(len=*), intent(in) :: path
    type(weather_record), allocatable, intent(out) :: records(:)
    integer, intent(out) :: status
    character(len=*), intent(out) :: message
    character(len=4096) :: line
    character(len=512) :: fields(8)
    integer :: unit, ios, n, i, nf
    logical :: date_ok

    status = 0; message = ""
    open(newunit=unit, file=path, status="old", action="read", iostat=ios)
    if (ios /= 0) then; status = 10; message = "Cannot open observations TSV"; allocate(records(0)); return; end if
    read(unit, "(A)", iostat=ios) line
    if (trim(line) /= "location_key"//achar(9)//"location_id"//achar(9)//"location_name"//achar(9)// &
        "date"//achar(9)//"tmin_c"//achar(9)//"tmax_c"//achar(9)//"precip_mm") then
      status = 11; message = "Unexpected observations-v1 header"; allocate(records(0)); close(unit); return
    end if
    n = 0
    do; read(unit, "(A)", iostat=ios) line; if (ios /= 0) exit; if (len_trim(line) > 0) n = n + 1; end do
    rewind(unit); read(unit, "(A)") line; allocate(records(n)); i = 0
    do
      read(unit, "(A)", iostat=ios) line; if (ios /= 0) exit; if (len_trim(line) == 0) cycle
      i = i + 1; call split_tsv(line, fields, nf)
      if (nf /= 7) then; call fail(status,message,12,"Expected 7 tab-separated fields",i); close(unit); return; end if
      read(fields(1), *, iostat=ios) records(i)%location_key
      if (ios /= 0 .or. records(i)%location_key < 1) then; call fail(status,message,13,"Invalid location_key",i); close(unit); return; end if
      records(i)%location_id = trim(fields(2)); records(i)%location_name = trim(fields(3)); records(i)%date = trim(fields(4))
      if (len_trim(records(i)%location_id) == 0 .or. len_trim(records(i)%location_name) == 0) then
        call fail(status,message,14,"Empty location identifier or name",i); close(unit); return
      end if
      call parse_iso_date(records(i)%date, records(i)%ordinal_date, date_ok)
      if (.not. date_ok) then; call fail(status,message,15,"Invalid ISO date",i); close(unit); return; end if
      read(fields(5), *, iostat=ios) records(i)%tmin_c; if (ios /= 0) then; call fail(status,message,16,"Invalid tmin_c",i); close(unit); return; end if
      read(fields(6), *, iostat=ios) records(i)%tmax_c; if (ios /= 0) then; call fail(status,message,17,"Invalid tmax_c",i); close(unit); return; end if
      read(fields(7), *, iostat=ios) records(i)%precip_mm; if (ios /= 0) then; call fail(status,message,18,"Invalid precip_mm",i); close(unit); return; end if
      if (.not. ieee_is_finite(records(i)%tmin_c) .or. .not. ieee_is_finite(records(i)%tmax_c) .or. &
          .not. ieee_is_finite(records(i)%precip_mm)) then; call fail(status,message,19,"Non-finite value",i); close(unit); return; end if
      if (records(i)%tmin_c > records(i)%tmax_c) then; call fail(status,message,20,"tmin_c exceeds tmax_c",i); close(unit); return; end if
      if (records(i)%precip_mm < 0.0_dp) then; call fail(status,message,21,"Negative precipitation",i); close(unit); return; end if
    end do
    close(unit)
  end subroutine read_weather_tsv

  subroutine read_seasons_tsv(path, windows, status, message)
    character(len=*), intent(in) :: path
    type(crop_window), allocatable, intent(out) :: windows(:)
    integer, intent(out) :: status
    character(len=*), intent(out) :: message
    character(len=4096) :: line
    character(len=512) :: fields(8)
    integer :: unit, ios, n, i, nf
    logical :: ok1, ok2
    status = 0; message = ""
    open(newunit=unit, file=path, status="old", action="read", iostat=ios)
    if (ios /= 0) then; status=30; message="Cannot open seasons TSV"; allocate(windows(0)); return; end if
    read(unit,"(A)",iostat=ios) line
    if (trim(line) /= "season_id"//achar(9)//"location_key"//achar(9)//"location_id"//achar(9)// &
        "season_name"//achar(9)//"season_year"//achar(9)//"start_date"//achar(9)//"end_date") then
      status=31; message="Unexpected seasons-v1 header"; allocate(windows(0)); close(unit); return
    end if
    n=0; do; read(unit,"(A)",iostat=ios) line; if(ios/=0)exit; if(len_trim(line)>0)n=n+1; end do
    rewind(unit); read(unit,"(A)") line; allocate(windows(n)); i=0
    do
      read(unit,"(A)",iostat=ios) line; if(ios/=0)exit; if(len_trim(line)==0)cycle
      i=i+1; call split_tsv(line,fields,nf)
      if(nf/=7)then;call fail(status,message,32,"Expected 7 tab-separated fields",i);close(unit);return;end if
      windows(i)%season_id=trim(fields(1)); read(fields(2),*,iostat=ios) windows(i)%location_key
      if(ios/=0.or.windows(i)%location_key<1)then;call fail(status,message,33,"Invalid location_key",i);close(unit);return;end if
      windows(i)%location_id=trim(fields(3)); windows(i)%season_name=trim(fields(4))
      read(fields(5),*,iostat=ios) windows(i)%season_year
      if(ios/=0.or.windows(i)%season_year<1)then;call fail(status,message,34,"Invalid season_year",i);close(unit);return;end if
      windows(i)%start_date=trim(fields(6)); windows(i)%end_date=trim(fields(7))
      call parse_iso_date(windows(i)%start_date,windows(i)%start_ordinal,ok1)
      call parse_iso_date(windows(i)%end_date,windows(i)%end_ordinal,ok2)
      if(.not.ok1.or..not.ok2.or.windows(i)%end_ordinal<windows(i)%start_ordinal)then
        call fail(status,message,35,"Invalid season date interval",i);close(unit);return
      end if
      if(len_trim(windows(i)%season_id)==0.or.len_trim(windows(i)%location_id)==0.or.len_trim(windows(i)%season_name)==0)then
        call fail(status,message,36,"Empty season identifier, location identifier, or name",i);close(unit);return
      end if
    end do
    close(unit)
  end subroutine read_seasons_tsv

  subroutine write_results_tsv(path, results, status, message)
    character(len=*), intent(in) :: path
    type(exposure_result), intent(in) :: results(:)
    integer, intent(out) :: status
    character(len=*), intent(out) :: message
    integer :: unit, ios, i
    character(len=1), parameter :: t=achar(9)
    status=0;message=""
    open(newunit=unit,file=path,status="replace",action="write",iostat=ios)
    if(ios/=0)then;status=40;message="Cannot create results TSV";return;end if
    write(unit,"(A)") "location_key"//t//"location_id"//t//"location_name"//t//"season_id"//t//"season_name"//t// &
      "season_year"//t//"start_date"//t//"end_date"//t//"gdd_c_day"//t//"edd_c_day"//t//"hdd_c_day"//t// &
      "precip_mm"//t//"observed_days"//t//"expected_days"//t//"coverage_fraction"//t//"qc_status"
    do i=1,size(results)
      write(unit,'(*(g0))') &
        results(i)%location_key,t,trim(results(i)%location_id),t,trim(results(i)%location_name),t, &
        trim(results(i)%season_id),t,trim(results(i)%season_name),t,results(i)%season_year,t, &
        trim(results(i)%start_date),t,trim(results(i)%end_date),t,results(i)%gdd,t,results(i)%edd,t, &
        results(i)%hdd,t,results(i)%precip_mm,t,results(i)%observed_days,t,results(i)%expected_days,t, &
        results(i)%coverage_fraction,t,trim(results(i)%qc_status)
    end do
    close(unit)
  end subroutine write_results_tsv

end module tsv_io
