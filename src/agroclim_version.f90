module agroclim_version
  implicit none
  private
  public :: version_string, schema_version
  character(len=*), parameter :: version_string = "1.0.0"
  character(len=*), parameter :: schema_version = "1.0"
end module agroclim_version
