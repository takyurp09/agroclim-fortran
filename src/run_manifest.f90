module run_manifest
  use, intrinsic :: iso_fortran_env, only: compiler_version, compiler_options
  use climate_types, only: exposure_config
  use agroclim_version, only: version_string, schema_version
  implicit none
  private
  public :: write_manifest_json

contains
  subroutine write_manifest_json(path, observations_path, seasons_path, output_path, config, &
                                 observations_count, seasons_count, threads, status, message)
    character(len=*),intent(in)::path,observations_path,seasons_path,output_path
    type(exposure_config),intent(in)::config
    integer,intent(in)::observations_count,seasons_count,threads
    integer,intent(out)::status
    character(len=*),intent(out)::message
    integer::unit,ios,values(8)
    character(len=32)::timestamp
    status=0;message="";call date_and_time(values=values)
    write(timestamp,'(I4.4,"-",I2.2,"-",I2.2,"T",I2.2,":",I2.2,":",I2.2)') &
      values(1),values(2),values(3),values(5),values(6),values(7)
    open(newunit=unit,file=path,status="replace",action="write",iostat=ios)
    if(ios/=0)then;status=60;message="Cannot create run manifest";return;end if
    write(unit,'(A)')'{'
    write(unit,'(A)')'  "manifest_schema": "agroclim-run-manifest-v1",'
    write(unit,'(A)')'  "software_version": "'//version_string//'",'
    write(unit,'(A)')'  "result_schema_version": "'//schema_version//'",'
    write(unit,'(A)')'  "created_local_time": "'//trim(timestamp)//'",'
    write(unit,'(A)')'  "algorithm": "sinusoidal-degree-days-v1",'
    write(unit,'(A)')'  "observations_path": "'//trim(observations_path)//'",'
    write(unit,'(A)')'  "seasons_path": "'//trim(seasons_path)//'",'
    write(unit,'(A)')'  "output_path": "'//trim(output_path)//'",'
    write(unit,'(A,I0,A)')'  "observation_rows": ',observations_count,','
    write(unit,'(A,I0,A)')'  "season_rows": ',seasons_count,','
    write(unit,'(A,I0,A)')'  "threads": ',threads,','
    write(unit,'(A)')'  "parameters": {'
    write(unit,'(A,F0.6,A)')'    "gdd_base_c": ',config%gdd_base_c,','
    write(unit,'(A,F0.6,A)')'    "gdd_cap_c": ',config%gdd_cap_c,','
    write(unit,'(A,F0.6,A)')'    "edd_threshold_c": ',config%edd_threshold_c,','
    write(unit,'(A,F0.6,A)')'    "hdd_threshold_c": ',config%hdd_threshold_c,','
    write(unit,'(A,F10.6)')'    "minimum_coverage": ',config%minimum_coverage
    write(unit,'(A)')'  },'
    write(unit,'(A)')'  "compiler": "'//trim(compiler_version())//'",'
    write(unit,'(A)')'  "compiler_options": "'//trim(compiler_options())//'"'
    write(unit,'(A)')'}'
    close(unit)
  end subroutine write_manifest_json
end module run_manifest
