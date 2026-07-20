#!/usr/bin/env bash
set -euo pipefail

mkdir -p results
output="results/benchmark_results.csv"
echo "observations,threads,seconds,million_obs_per_second,checksum" > "$output"

for observations in 100000 1000000 10000000; do
  for threads in 1 2 4 8; do
    build/benchmark_kernel "$observations" "$threads" | tail -n 1 >> "$output"
  done
done

echo "Wrote $output"
