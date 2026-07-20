#!/usr/bin/env bash
#SBATCH --job-name=agroclim
#SBATCH --cpus-per-task=8
#SBATCH --mem=4G
#SBATCH --time=00:15:00
#SBATCH --output=agroclim-%j.out

set -euo pipefail
export OMP_NUM_THREADS="${SLURM_CPUS_PER_TASK}"

./build/agroclim compute \
  --daily examples/daily_weather.csv \
  --windows examples/crop_windows.csv \
  --output results/exposure-slurm.csv \
  --threads "${OMP_NUM_THREADS}"
