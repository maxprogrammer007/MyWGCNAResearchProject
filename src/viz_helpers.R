# src/viz_helpers.R
# =========================
# Visualization helpers for WGCNA outputs

# Required packages
if (!requireNamespace("ggplot2", quietly=TRUE)) install.packages("ggplot2")
if (!requireNamespace("viridis", quietly=TRUE)) install.packages("viridis")
if (!requireNamespace("pheatmap", quietly=TRUE)) install.packages("pheatmap")
if (!requireNamespace("reshape2", quietly=TRUE)) install.packages("reshape2")

library(ggplot2)
library(viridis)
library(pheatmap)
library(reshape2)

#' Theme for dendrogram plots
#'
#' @return ggplot2 theme object
themeDendrogram <- function() {
  theme_minimal(base_size = 14) +
    theme(
      axis.title = element_blank(),
      axis.text = element_blank(),
      panel.grid = element_blank()
    )
}

#' Plot TOM heatmap ordered by geneTree
#'
#' @param tom TOM similarity matrix
#' @param geneTree hclust object
#' @param moduleColors Vector of module colors corresponding to genes
#' @param heatmap_file Optional path to save heatmap image
#' @return pheatmap object
plotTOMHeatmap <- function(tom, geneTree, moduleColors, heatmap_file = NULL) {
  ord <- geneTree$order
  mat_ord <- as.matrix(tom)[ord, ord]
  ann_row <- data.frame(Module = moduleColors[ord])
  rownames(ann_row) <- rownames(mat_ord)
  
  ph <- pheatmap(
    mat_ord,
    color = viridis(100),
    cluster_rows = FALSE,
    cluster_cols = FALSE,
    annotation_row = ann_row,
    show_rownames = FALSE,
    show_colnames = FALSE
  )
  if (!is.null(heatmap_file)) {
    ggsave(heatmap_file, plot = ph[[4]], width = 8, height = 6)
    loginfo("Saved TOM heatmap to %s", heatmap_file)
  }
  return(ph)
}

#' Plot module-trait correlation heatmap
#'
#' @param moduleTraitCor Matrix of correlations
#' @param moduleTraitP Matrix of p-values (same dims as moduleTraitCor)
#' @return ggplot2 object
plotModuleTraitCorr <- function(moduleTraitCor, moduleTraitP = NULL) {
  df <- melt(moduleTraitCor)
  names(df) <- c("Module", "Trait", "Correlation")
  p <- ggplot(df, aes(x = Trait, y = Module, fill = Correlation)) +
    geom_tile() +
    scale_fill_gradient2(low = "blue", mid = "white", high = "red", midpoint = 0) +
    theme_minimal() +
    labs(x = NULL, y = NULL)
  
  if (!is.null(moduleTraitP)) {
    df$p <- melt(moduleTraitP)$value
    p <- p + geom_text(aes(label = ifelse(p < 0.05, "*", "")), color = "black")
  }
  return(p)
}
