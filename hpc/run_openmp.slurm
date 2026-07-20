#!/usr/bin/env bash
#SBATCH --job-name=agroclim
#SBATCH --cpus-per-task=8
#SBATCH --mem=4G
#SBATCH --time=00:15:00
#SBATCH --output=agroclim-%j.out

set -euo pipefail
export OMP_NUM_THREADS="${SLURM_CPUS_PER_TASK}"

python3 python/run_with_provenance.py \
  --executable build/agroclim \
  --observations examples/nasa-power/data/processed/observations.tsv \
  --seasons examples/nasa-power/seasons.tsv \
  --output results/exposure-slurm.tsv \
  --manifest results/manifest-slurm.json \
  --threads "${OMP_NUM_THREADS}"
