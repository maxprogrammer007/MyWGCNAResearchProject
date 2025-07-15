# module_detection.R
# ====================
# Dynamic tree cutting & module merging

library(WGCNA)
library(dynamicTreeCut)

#' Detect modules from dissTOM
#'
#' @param dissTOM TOM dissimilarity matrix
#' @param deepSplit sensitivity (0–4)
#' @param minModuleSize minimum cluster size
#' @param method clustering linkage ("average", etc.)
#' @return list(geneTree, moduleColors)
detectModules <- function(
    dissTOM,
    deepSplit = 2,
    minModuleSize = 30,
    method = "average"
) {
  geneTree <- flashClust(as.dist(dissTOM), method = method)
  dynMods <- cutreeDynamic(
    dendro = geneTree,
    distM = dissTOM,
    deepSplit = deepSplit,
    pamRespectsDendro = FALSE,
    minClusterSize = minModuleSize
  )
  moduleColors <- labels2colors(dynMods)
  list(geneTree = geneTree, moduleColors = moduleColors)
}

#' Merge similar modules based on eigengene clustering
#'
#' @param datExpr samples × genes matrix
#' @param moduleColors vector of module assignments
#' @param cutHeight merge threshold (e.g. 0.25)
#' @return list(mergedColors, mergeInfo)
mergeModules <- function(
    datExpr,
    moduleColors,
    cutHeight = 0.25
) {
  merge <- mergeCloseModules(
    datExpr,
    moduleColors,
    cutHeight = cutHeight,
    verbose = 0
  )
  list(mergedColors = merge$colors, mergeInfo = merge)
}
