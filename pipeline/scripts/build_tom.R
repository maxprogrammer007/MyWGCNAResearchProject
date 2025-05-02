# pipeline/scripts/build_tom.R
# -----------------------------
suppressPackageStartupMessages({
  library(optparse)
  library(MyWGCNAResearchProject)
})

opt <- parse_args(OptionParser(option_list = list(
  make_option(c("-e", "--expr"), type = "character", help = "Normalized RDS input"),
  make_option(c("-p", "--power"), type = "character", help = "Power RDS input"),
  make_option(c("-o", "--output"), type = "character", help = "TOM RDS output"),
  make_option(c("--networkType"), type = "character", default = "unsigned"),
  make_option(c("--corType"), type = "character", default = "pearson")
)))

dir.create(dirname(opt$output), recursive = TRUE, showWarnings = FALSE)

expr_norm <- readRDS(opt$expr)
power     <- readRDS(opt$power)
datExpr   <- t(expr_norm)

res <- constructNetwork(datExpr,
                        power       = power,
                        networkType = opt$networkType,
                        corType     = opt$corType)

saveRDS(res$TOM, file = opt$output)
