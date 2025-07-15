# pipeline/scripts/pick_soft_threshold.R
# --------------------------------------
suppressPackageStartupMessages({
  library(optparse)
  library(MyWGCNAResearchProject)
})

opt <- parse_args(OptionParser(option_list = list(
  make_option(c("-i", "--input"), type = "character", help = "Normalized RDS input"),
  make_option(c("-p", "--output-power"), type = "character", help = "Power RDS output"),
  make_option(c("-g", "--output-plot"), type = "character", help = "Plot PNG output"),
  make_option(c("--powers"), type = "character", default = "c(1:20)",
              help = "Candidate powers, e.g. 'c(1,2,3)'"),
  make_option(c("--networkType"), type = "character", default = "unsigned"),
  make_option(c("--corType"), type = "character", default = "pearson")
)))

dir.create(dirname(opt$`output-power`), recursive = TRUE, showWarnings = FALSE)

dir.create(dirname(opt$`output-plot`),  recursive = TRUE, showWarnings = FALSE)

expr_norm <- readRDS(opt$input)
datExpr <- t(expr_norm)

powers <- eval(parse(text = opt$powers))
res <- pickSoftPower(datExpr,
                     powers = powers,
                     networkType = opt$networkType,
                     corType     = opt$corType)

saveRDS(res$power, file = opt$`output-power`)

png(filename = opt$`output-plot`, width = 800, height = 600)
plotSoftPower(res$fitIndices)
dev.off()