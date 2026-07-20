FC := gfortran
BUILD := build
MODDIR := $(BUILD)/mod
FFLAGS_COMMON := -std=f2018 -Wall -Wextra -Wimplicit-interface -Wconversion-extra -ffree-line-length-none -J$(MODDIR) -I$(MODDIR)
FFLAGS_DEBUG := -O0 -g -fcheck=all -fbacktrace -ffpe-trap=invalid,zero,overflow
FFLAGS_RELEASE := -O3 -fopenmp

CORE_SRC := src/kinds.f90 src/agroclim_version.f90 src/calendar_dates.f90 src/degree_days.f90 \
	src/climate_types.f90 src/input_validation.f90 src/seasonal_aggregation.f90 src/agroclim.f90
APP_SRC := src/tsv_io.f90 src/run_manifest.f90 app/agroclim_cli.f90

.PHONY: all debug release test unit-test python-test integration-test example benchmark clean
all: release

$(BUILD) $(MODDIR):
	mkdir -p $@

debug: | $(BUILD) $(MODDIR)
	$(FC) $(FFLAGS_COMMON) $(FFLAGS_DEBUG) -fopenmp $(CORE_SRC) $(APP_SRC) -o $(BUILD)/agroclim

release: | $(BUILD) $(MODDIR)
	$(FC) $(FFLAGS_COMMON) $(FFLAGS_RELEASE) $(CORE_SRC) $(APP_SRC) -o $(BUILD)/agroclim

unit-test: | $(BUILD) $(MODDIR)
	$(FC) $(FFLAGS_COMMON) $(FFLAGS_DEBUG) src/kinds.f90 src/calendar_dates.f90 src/degree_days.f90 test/test_degree_days.f90 -o $(BUILD)/test_degree_days
	$(BUILD)/test_degree_days
	$(FC) $(FFLAGS_COMMON) $(FFLAGS_DEBUG) src/calendar_dates.f90 test/test_calendar_dates.f90 -o $(BUILD)/test_calendar_dates
	$(BUILD)/test_calendar_dates

python-test:
	PYTHONPATH=. python3 test/test_python_reference.py

example: release
	mkdir -p results
	python3 python/run_with_provenance.py --executable $(BUILD)/agroclim --observations examples/observations.tsv \
		--seasons examples/seasons.tsv --output results/exposures.tsv --manifest results/run-manifest.json \
		--minimum-coverage 0.02 --threads 2

integration-test: example
	python3 test/test_cli_validation.py
	PYTHONPATH=. python3 python/validate_parity.py --observations examples/observations.tsv \
		--seasons examples/seasons.tsv --fortran-output results/exposures.tsv
	$(BUILD)/agroclim aggregate --observations examples/observations.tsv --seasons examples/seasons.tsv \
		--output results/exposures-1.tsv --manifest results/manifest-1.json --minimum-coverage 0.02 --threads 1
	$(BUILD)/agroclim aggregate --observations examples/observations.tsv --seasons examples/seasons.tsv \
		--output results/exposures-4.tsv --manifest results/manifest-4.json --minimum-coverage 0.02 --threads 4
	cmp results/exposures-1.tsv results/exposures-4.tsv

test: unit-test python-test integration-test

benchmark: | $(BUILD) $(MODDIR)
	$(FC) $(FFLAGS_COMMON) $(FFLAGS_RELEASE) src/kinds.f90 src/degree_days.f90 benchmarks/benchmark_kernel.f90 -o $(BUILD)/benchmark_kernel
	python3 benchmarks/run_benchmarks.py

clean:
	$(RM) -r $(BUILD) results
