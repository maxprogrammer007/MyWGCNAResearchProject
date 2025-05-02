# dendrogram_generation.R
# =======================
# Robust functions for accurate and stable dendrogram generation in a WGCNA workflow

# Required packages
# Install if missing: BiocManager::install("WGCNA"), install.packages(c(
#   "flashClust","dynamicTreeCut","ggdendro","plotly","dendextend"))
library(WGCNA)
library(flashClust)
library(dynamicTreeCut)
library(ggdendro)
library(plotly)
library(dendextend)

# Enable multithreading
enableWGCNAThreads()

#' Generate a robust gene dendrogram based on TOM dissimilarity
#'
#' Performs QC, power selection, network construction, module detection,
#' and optional stability assessment via cophenetic correlation and bootstrapping.
#'
#' @param exprData Numeric matrix (genes × samples)
#' @param power Soft-thresholding power (auto-picked if NULL)
#' @param powers Candidate powers vector
#' @param minModuleSize Minimum module size
#' @param mergeCutHeight Merge threshold for modules
#' @param tomType "unsigned" or "signed"
#' @param corType "pearson" or "bicor"
#' @param deepSplit Dynamic tree cut sensitivity (0–4)
#' @param outlierZCut Z-score cutoff for sample removal
#' @param bootstrap Logical: perform bootstrap stability
#' @param nBoot Number of bootstrap iterations
#' @return List with power, datExpr, geneTree, moduleColors, dissTOM,
#'   copheneticCorr, stability
#'
generateRobustDendrogram <- function(
    exprData,
    power = NULL,
    powers = 1:20,
    minModuleSize = 30,
    mergeCutHeight = 0.25,
    tomType = "unsigned",
    corType = "pearson",
    deepSplit = 2,
    outlierZCut = 2.5,
    bootstrap = FALSE,
    nBoot = 100
) {
  # 0. Transpose & QC: remove genes with too many NAs
  datExpr <- t(exprData)
  naCounts <- rowSums(is.na(datExpr))
  datExpr <- datExpr[naCounts <= ncol(datExpr)*0.1, , drop = FALSE]
  
  # 1. Sample outlier detection
  sampleMeans <- rowMeans(datExpr, na.rm = TRUE)
  zSample <- scale(sampleMeans)
  outliers <- rownames(datExpr)[abs(zSample) > outlierZCut]
  if (length(outliers)) {
    warning("Removing outlier samples: ", paste(outliers, collapse=", "))
    datExpr <- datExpr[!rownames(datExpr) %in% outliers, , drop = FALSE]
  }
  
  # 2. Soft-threshold power selection
  if (is.null(power)) {
    sft <- pickSoftThreshold(
      datExpr,
      powerVector = powers,
      networkType = tomType,
      corFnc = if(corType=="bicor") bicor else cor,
      verbose = 0
    )
    power <- sft$powerEstimate
    if (is.na(power)) {
      power <- powers[which.max(sft$fitIndices[,"SFT.R.sq"])]
      message("Fallback power chosen: ", power)
    }
  }
  
  # 3. Adjacency & TOM
  adjMat <- adjacency(
    datExpr,
    power = power,
    type = tomType,
    corFnc = if(corType=="bicor") bicor else cor
  )
  tomMat <- TOMsimilarity(adjMat)
  dissTOM <- 1 - tomMat
  
  # 4. Gene clustering
  geneTree <- flashClust(as.dist(dissTOM), method="average")
  
  # 5. Dynamic tree cutting
  dynMods <- cutreeDynamic(
    dendro = geneTree,
    distM = dissTOM,
    deepSplit = deepSplit,
    pamRespectsDendro = FALSE,
    minClusterSize = minModuleSize
  )
  moduleColors <- labels2colors(dynMods)
  
  # 6. Module merging: only if modules beyond grey
  nonGrey <- setdiff(unique(moduleColors), "grey")
  if (length(nonGrey) == 0) {
    warning("Only grey module detected; skipping merge step.")
    mergedColors <- moduleColors
  } else {
    MEList <- moduleEigengenes(datExpr, colors = moduleColors)
    MEs <- MEList$eigengenes
    MEDiss <- 1 - cor(MEs)
    merged <- mergeCloseModules(
      datExpr,
      moduleColors,
      cutHeight = mergeCutHeight,
      verbose = 0
    )
    mergedColors <- merged$colors
  }
  
  # 7. Cophenetic correlation
  copheCorr <- cor(
    cophenetic(geneTree),
    as.dist(dissTOM),
    use = "pairwise.complete.obs"
  )
  
  # 8. Bootstrap stability
  stability <- NULL
  if (bootstrap) {
    stability <- replicate(nBoot, {
      idx <- sample(seq_len(nrow(datExpr)), nrow(datExpr), replace = TRUE)
      exprB <- datExpr[idx, , drop=FALSE]
      dissB <- 1 - TOMsimilarity(adjacency(exprB, power=power))
      treeB <- flashClust(as.dist(dissB), method="average")
      cor(cophenetic(treeB), cophenetic(geneTree), use="pairwise.complete.obs")
    })
  }
  
  # 9. Plot dendrogram
  plotDendroAndColors(
    geneTree,
    mergedColors,
    groupLabels = c("Modules"),
    main = "Robust Gene Dendrogram"
  )
  
  # Return
  list(
    power = power,
    datExpr = datExpr,
    geneTree = geneTree,
    moduleColors = mergedColors,
    dissTOM = dissTOM,
    copheneticCorr = copheCorr,
    stability = stability
  )
}

# Interactive dendrogram
plotInteractiveDendrogram <- function(geneTree, stability=NULL) {
  d <- dendro_data(as.dendrogram(geneTree))
  segs <- segment(d)
  p <- ggplot() +
    geom_segment(
      data = segs,
      aes(x=x,y=y,xend=xend,yend=yend,
          text = if (!is.null(stability)) 
            paste0("Stability: ", round(stability,3)) else NULL)
    ) +
    labs(title="Interactive Robust Gene Dendrogram") +
    theme_minimal()
  ggplotly(p, tooltip="text")
}
