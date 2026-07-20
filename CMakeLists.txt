cmake_minimum_required(VERSION 3.20)
project(AgroClimFortran VERSION 1.0.0 LANGUAGES Fortran)

include(GNUInstallDirs)
include(CTest)
find_package(OpenMP REQUIRED COMPONENTS Fortran)

set(AGROCLIM_SOURCES
  src/kinds.f90
  src/agroclim_version.f90
  src/calendar_dates.f90
  src/degree_days.f90
  src/climate_types.f90
  src/input_validation.f90
  src/seasonal_aggregation.f90
  src/agroclim.f90
  src/tsv_io.f90
  src/run_manifest.f90)

add_library(agroclim_fortran ${AGROCLIM_SOURCES})
add_library(AgroClim::agroclim ALIAS agroclim_fortran)
target_link_libraries(agroclim_fortran PUBLIC OpenMP::OpenMP_Fortran)
set_target_properties(agroclim_fortran PROPERTIES
  Fortran_MODULE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/modules"
  OUTPUT_NAME agroclim)
target_include_directories(agroclim_fortran PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/modules>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/agroclim>)

add_executable(agroclim app/agroclim_cli.f90)
target_link_libraries(agroclim PRIVATE AgroClim::agroclim)

if(BUILD_TESTING)
  add_executable(test_degree_days test/test_degree_days.f90)
  target_link_libraries(test_degree_days PRIVATE AgroClim::agroclim)
  add_test(NAME degree-days COMMAND test_degree_days)
  add_executable(test_calendar_dates test/test_calendar_dates.f90)
  target_link_libraries(test_calendar_dates PRIVATE AgroClim::agroclim)
  add_test(NAME calendar-dates COMMAND test_calendar_dates)
endif()

install(TARGETS agroclim_fortran agroclim EXPORT AgroClimTargets
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/modules/"
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/agroclim FILES_MATCHING PATTERN "*.mod")
install(EXPORT AgroClimTargets NAMESPACE AgroClim:: DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/AgroClim)
