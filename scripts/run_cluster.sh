#!/usr/bin/env bash
# scripts/run_cluster.sh
# ----------------------
# Usage: ./scripts/run_cluster.sh
# Submits Snakemake jobs to the cluster (via sbatch).

# Number of parallel jobs
JOBS=100

echo "🐍 Submitting Snakemake workflow to cluster (up to $JOBS jobs)..."
snakemake --jobs $JOBS \
          --cluster-config config/cluster.yaml \
          --cluster "sbatch -A {cluster.account} -t {cluster.time} -n {cluster.ntasks} --mem={cluster.mem}" \
          --latency-wait 60 \
          --rerun-incomplete \
          --snakefile pipeline/Snakefile \
          --configfile config/default.yaml \
          --directory .
