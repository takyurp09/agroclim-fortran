program agroclim_cli
  use agroclim, only: dp, version_string, weather_record, crop_window, exposure_config, exposure_result, aggregate_exposures
  use tsv_io, only: read_weather_tsv, read_seasons_tsv, write_results_tsv
  use input_validation, only: validate_and_sort_inputs
  use run_manifest, only: write_manifest_json
  use omp_lib, only: omp_set_num_threads
  implicit none
  type(weather_record),allocatable::weather(:)
  type(crop_window),allocatable::windows(:)
  type(exposure_result),allocatable::results(:)
  type(exposure_config)::config
  character(len=512)::observations_path,seasons_path,output_path,manifest_path,arg,message
  integer::threads,i,ios,status
  observations_path="";seasons_path="";output_path="";manifest_path="";threads=1
  if(command_argument_count()==0)then;call print_help();stop;end if
  i=1
  do while(i<=command_argument_count())
    call get_command_argument(i,arg)
    select case(trim(arg))
    case("aggregate")
    case("--help","-h");call print_help();stop
    case("--version");print '(A)',"agroclim "//version_string;stop
    case("--observations");call next_value(i,observations_path)
    case("--seasons");call next_value(i,seasons_path)
    case("--output");call next_value(i,output_path)
    case("--manifest");call next_value(i,manifest_path)
    case("--gdd-base");call next_real(i,config%gdd_base_c,"--gdd-base")
    case("--gdd-cap");call next_real(i,config%gdd_cap_c,"--gdd-cap")
    case("--edd-threshold");call next_real(i,config%edd_threshold_c,"--edd-threshold")
    case("--hdd-threshold");call next_real(i,config%hdd_threshold_c,"--hdd-threshold")
    case("--minimum-coverage");call next_real(i,config%minimum_coverage,"--minimum-coverage")
    case("--threads");call next_value(i,arg);read(arg,*,iostat=ios)threads;if(ios/=0.or.threads<1)call fatal("Invalid --threads")
    case default;call fatal("Unknown argument: "//trim(arg))
    end select
    i=i+1
  end do
  if(len_trim(observations_path)==0.or.len_trim(seasons_path)==0.or.len_trim(output_path)==0.or.len_trim(manifest_path)==0)&
    call fatal("--observations, --seasons, --output, and --manifest are required")
  call read_weather_tsv(trim(observations_path),weather,status,message);if(status/=0)call fatal(message)
  call read_seasons_tsv(trim(seasons_path),windows,status,message);if(status/=0)call fatal(message)
  call validate_and_sort_inputs(weather,windows,config,status,message);if(status/=0)call fatal(message)
  call omp_set_num_threads(threads)
  call aggregate_exposures(weather,windows,config,results)
  call write_results_tsv(trim(output_path),results,status,message);if(status/=0)call fatal(message)
  call write_manifest_json(trim(manifest_path),trim(observations_path),trim(seasons_path),trim(output_path),config, &
    size(weather),size(windows),threads,status,message);if(status/=0)call fatal(message)
  print '(A,I0,A,I0,A)',"Aggregated ",size(weather)," observations into ",size(results)," explicit seasons."
contains
  subroutine next_value(index,value)
    integer,intent(inout)::index
    character(len=*),intent(out)::value
    if(index>=command_argument_count())call fatal("Missing value after option")
    index=index+1;call get_command_argument(index,value)
    if(len_trim(value)==0)call fatal("Empty option value")
  end subroutine
  subroutine next_real(index,value,name)
    integer,intent(inout)::index
    real(dp),intent(out)::value
    character(len=*),intent(in)::name
    character(len=512)::text
    call next_value(index,text);read(text,*,iostat=ios)value;if(ios/=0)call fatal("Invalid value for "//name)
  end subroutine
  subroutine fatal(text)
    character(len=*),intent(in)::text
    write(*,'(A)')"agroclim: error: "//trim(text);stop 2
  end subroutine
  subroutine print_help()
    print '(A)',"AgroClim-F "//version_string//" - validated crop-season climate exposure"
    print '(A)',"Usage: agroclim aggregate --observations FILE --seasons FILE --output FILE --manifest FILE [options]"
    print '(A)',"Options: --gdd-base 8 --gdd-cap 30 --edd-threshold 30 --hdd-threshold 10"
    print '(A)',"         --minimum-coverage 0.95 --threads N"
  end subroutine
end program agroclim_cli
