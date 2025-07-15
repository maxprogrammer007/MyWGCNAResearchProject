# data_preprocessing.R
# ====================
# Functions to load, QC-filter and normalize expression data

# dependencies
library(WGCNA)
if (!requireNamespace("DESeq2", quietly=TRUE)) {
  message("installing DESeq2 for VST normalization...")
  BiocManager::install("DESeq2")
}
library(DESeq2)

#' Load expression matrix (genes × samples)
#'
#' @param file path to CSV/TSV
#' @param sep field separator (',' or '\t')
#' @param row.names column for gene IDs
#' @return numeric matrix
loadExpressionData <- function(file, sep = ",", row.names = 1) {
  df <- read.csv(file, sep = sep, row.names = row.names, check.names = FALSE)
  as.matrix(df)
}

#' Filter genes by variance
#'
#' @param exprData genes × samples matrix
#' @param topN number of highest-variance genes to keep
#' @return filtered matrix
filterGenesByVariance <- function(exprData, topN = 10000) {
  vars <- apply(exprData, 1, var, na.rm = TRUE)
  keep <- order(vars, decreasing = TRUE)[seq_len(min(topN, length(vars)))]
  exprData[keep, , drop = FALSE]
}

#' Detect & remove outlier samples by mean-expression Z-score
#'
#' @param datExpr samples × genes matrix
#' @param zCut Z-score cutoff
#' @return cleaned datExpr
detectOutlierSamples <- function(datExpr, zCut = 2.5) {
  sampleMeans <- rowMeans(datExpr, na.rm = TRUE)
  z <- scale(sampleMeans)
  out <- which(abs(z) > zCut)
  if (length(out)) {
    warning("Removing outlier samples: ", paste(rownames(datExpr)[out], collapse = ", "))
    datExpr <- datExpr[-out, , drop = FALSE]
  }
  datExpr
}

#' Normalize using log2 or variance-stabilizing transform (VST)
#'
#' @param exprData raw counts genes × samples
#' @param method "log2" or "vst"
#' @return normalized matrix
normalizeExpression <- function(exprData, method = c("log2", "vst")) {
  method <- match.arg(method)
  if (method == "log2") {
    log2(exprData + 1)
  } else {
    dds <- DESeqDataSetFromMatrix(countData = exprData,
                                  colData = DataFrame(row = colnames(exprData)),
                                  design = ~ 1)
    vst(dds, blind = TRUE) |> assay()
  }
}
