#!/usr/bin/env bash
# scripts/run_local.sh
# --------------------
# Usage: ./scripts/run_local.sh [pipeline|shiny]
# Default: shiny

MODE=${1:-shiny}

# Load R package in place and start Shiny
if [ "$MODE" = "shiny" ]; then
  echo "🚀 Launching Shiny app (development mode)..."
  Rscript -e " \
    if (!requireNamespace('devtools',quietly=TRUE)) install.packages('devtools'); \
    devtools::load_all('Rpackage'); \
    shiny::runApp('Rpackage/inst/shiny', launch.browser=TRUE) \
  "
  exit $?
fi

# Run the Snakemake pipeline locally
if [ "$MODE" = "pipeline" ]; then
  echo "🐍 Running Snakemake pipeline..."
  snakemake --cores 4 \
            --snakefile pipeline/Snakefile \
            --configfile config/default.yaml \
            --directory .
  exit $?
fi

echo "Unknown mode: $MODE. Use 'pipeline' or 'shiny'."
exit 1
