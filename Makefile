FC := gfortran
BUILD := build
MODDIR := $(BUILD)/mod
FFLAGS_COMMON := -std=f2018 -Wall -Wextra -Wimplicit-interface -Wconversion-extra -ffree-line-length-none -J$(MODDIR) -I$(MODDIR)
FFLAGS_DEBUG := -O0 -g -fcheck=all -fbacktrace -ffpe-trap=invalid,zero,overflow
FFLAGS_RELEASE := -O3 -fopenmp

CORE_SRC := src/kinds.f90 src/degree_days.f90 src/climate_types.f90 src/csv_io.f90 src/seasonal_aggregation.f90

.PHONY: all debug release fortran-test python-test parity test example benchmark clean

all: release

$(BUILD) $(MODDIR):
	mkdir -p $@

debug: | $(BUILD) $(MODDIR)
	$(FC) $(FFLAGS_COMMON) $(FFLAGS_DEBUG) -fopenmp $(CORE_SRC) app/agroclim_cli.f90 -o $(BUILD)/agroclim

release: | $(BUILD) $(MODDIR)
	$(FC) $(FFLAGS_COMMON) $(FFLAGS_RELEASE) $(CORE_SRC) app/agroclim_cli.f90 -o $(BUILD)/agroclim

fortran-test: | $(BUILD) $(MODDIR)
	$(FC) $(FFLAGS_COMMON) $(FFLAGS_DEBUG) src/kinds.f90 src/degree_days.f90 test/test_degree_days.f90 -o $(BUILD)/test_degree_days
	$(BUILD)/test_degree_days

python-test:
	PYTHONPATH=. python3 test/test_python_reference.py

parity: example
	PYTHONPATH=. python3 python/validate_parity.py --daily examples/daily_weather.csv --windows examples/crop_windows.csv --fortran-output results/exposure.csv
	$(BUILD)/agroclim compute --daily examples/daily_weather.csv --windows examples/crop_windows.csv --output results/exposure-1-thread.csv --threads 1
	$(BUILD)/agroclim compute --daily examples/daily_weather.csv --windows examples/crop_windows.csv --output results/exposure-4-threads.csv --threads 4
	cmp results/exposure-1-thread.csv results/exposure-4-threads.csv

test: fortran-test python-test parity

example: release
	mkdir -p results
	$(BUILD)/agroclim compute --daily examples/daily_weather.csv --windows examples/crop_windows.csv --output results/exposure.csv --threads 2

benchmark: | $(BUILD) $(MODDIR)
	$(FC) $(FFLAGS_COMMON) $(FFLAGS_RELEASE) src/kinds.f90 src/degree_days.f90 benchmarks/benchmark_kernel.f90 -o $(BUILD)/benchmark_kernel
	bash benchmarks/run_benchmarks.sh

clean:
	rm -rf $(BUILD) results
