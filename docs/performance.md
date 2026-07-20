# Preliminary performance

Local smoke benchmark on 2026-07-20:

- Architecture: Apple arm64
- Operating system: macOS 26.5.1
- Compiler: GNU Fortran 15.2.0
- Compiler options: `-O3 -fopenmp`

Kernel throughput for 10 million synthetic daily observations:

| Threads | Seconds | Million observations/second | Speedup |
|---:|---:|---:|---:|
| 1 | 0.1408 | 71.0 | 1.00 |
| 2 | 0.0725 | 138.0 | 1.94 |
| 4 | 0.0360 | 277.9 | 3.91 |
| 8 | 0.0208 | 480.8 | 6.77 |

These are preliminary single-run kernel measurements, not claims about
end-to-end ERA5 processing. CSV parsing, seasonal grouping, storage, and
geospatial preprocessing are excluded. Repeated Linux and cluster benchmarks
should be added before using performance numbers in an application.

Checksums were identical across thread counts. Complete seasonal CSV output was
also byte-identical with one and eight OpenMP threads.
