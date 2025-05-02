# network_construction.R
# =======================
# Build adjacency and TOM matrices

library(WGCNA)

#' Construct network adjacency and TOM dissimilarity
#'
#' @param datExpr samples × genes matrix
#' @param power soft-thresholding power
#' @param networkType "unsigned" or "signed"
#' @param corType "pearson" or "bicor"
#' @return list(adjacency, TOM, dissTOM)
constructNetwork <- function(
    datExpr,
    power,
    networkType = "unsigned",
    corType = "pearson"
) {
  corFnc <- if (corType == "bicor") bicor else cor
  adj <- adjacency(
    datExpr,
    power = power,
    type = networkType,
    corFnc = corFnc
  )
  TOM <- TOMsimilarity(adj)
  dissTOM <- 1 - TOM
  list(adjacency = adj, TOM = TOM, dissTOM = dissTOM)
}
