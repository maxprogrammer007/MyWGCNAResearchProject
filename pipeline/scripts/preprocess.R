#!/usr/bin/env Rscript

# pipeline/scripts/preprocess.R
# -----------------------------
# Load & filter genes, then normalize expression
suppressPackageStartupMessages({
  library(optparse)
  library(MyWGCNAResearchProject)
})

opt <- parse_args(OptionParser(option_list = list(
  make_option(c("-i", "--input"), type = "character", help = "Raw expression CSV"),
  make_option(c("-o", "--output"), type = "character", help = "Normalized RDS output"),
  make_option(c("-m", "--method"), type = "character", default = "vst",
              help = "Normalization: 'log2' or 'vst'"),
  make_option(c("-t", "--topN"), type = "integer", default = 10000,
              help = "Top N variable genes"))
))

dir.create(dirname(opt$output), recursive = TRUE, showWarnings = FALSE)

expr <- loadExpressionData(opt$input)
expr_filt <- filterGenesByVariance(expr, topN = opt$topN)
expr_norm <- normalizeExpression(expr_filt, method = opt$method)

saveRDS(expr_norm, file = opt$output)