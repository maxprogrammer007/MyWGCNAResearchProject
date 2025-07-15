# pipeline/scripts/detect_modules.R
# ---------------------------------
suppressPackageStartupMessages({
  library(optparse)
  library(MyWGCNAResearchProject)
})

opt <- parse_args(OptionParser(option_list = list(
  make_option(c("-x","--expr"), type = "character", help = "Normalized RDS input"),
  make_option(c("-t","--tom"),  type = "character", help = "TOM RDS input"),
  make_option(c("-p","--out-plot"),    type = "character", help = "Dendrogram PNG output"),
  make_option(c("-m","--out-modules"), type = "character", help = "Modules TSV output"),
  make_option(c("--deepSplit"),     type = "integer", default = 2),
  make_option(c("--minModuleSize"), type = "integer", default = 30),
  make_option(c("--mergeCutHeight"),type = "double",  default = 0.25),
  make_option(c("--outlierZ"),      type = "double",  default = 2.5),
  make_option(c("--bootstrap"),     type = "logical", default = FALSE),
  make_option(c("--nBoot"),         type = "integer", default = 100)
)))

dir.create(dirname(opt$`out-plot`),    recursive = TRUE, showWarnings = FALSE)

dir.create(dirname(opt$`out-modules`), recursive = TRUE, showWarnings = FALSE)

expr_norm <- readRDS(opt$expr)
tomMat    <- readRDS(opt$tom)
dissTOM   <- 1 - tomMat

mods   <- detectModules(dissTOM,
                        deepSplit     = opt$deepSplit,
                        minModuleSize = opt$minModuleSize)

moduleColors <- mods$moduleColors
geneTree     <- mods$geneTree

# Merge
merged <- mergeModules(t(expr_norm),
                       moduleColors,
                       cutHeight = opt$mergeCutHeight)
mergedColors <- merged$mergedColors

# Write modules
dfMods <- data.frame(Gene = names(mergedColors),
                     Module = mergedColors,
                     stringsAsFactors = FALSE)
write.table(dfMods,
            file = opt$`out-modules`,
            sep = "\t", quote = FALSE, row.names = FALSE)

# Plot dendrogram
png(filename = opt$`out-plot`, width = 1000, height = 800)
plotDendroAndColors(geneTree,
                    mergedColors,
                    groupLabels = c("Modules"),
                    main = "Gene dendrogram and module colors")
dev.off()
