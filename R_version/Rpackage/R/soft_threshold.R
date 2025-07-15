# soft_threshold.R
# =================
# Auto-pick and visualize soft-thresholding power for scale-free topology

library(WGCNA)

#' Pick soft-thresholding power
#'
#' @param datExpr samples × genes matrix
#' @param powers candidate integer vector
#' @param networkType "unsigned" or "signed"
#' @param corType "pearson" or "bicor"
#' @param R2cut minimum scale-free R²
#' @return list(power, fitIndices)
pickSoftPower <- function(
    datExpr,
    powers = 1:20,
    networkType = "unsigned",
    corType = "pearson",
    R2cut = 0.80
) {
  corFnc <- if (corType == "bicor") bicor else cor
  sft <- pickSoftThreshold(
    datExpr,
    powerVector = powers,
    networkType = networkType,
    corFnc = corFnc,
    verbose = 0
  )
  power <- sft$powerEstimate
  if (is.na(power) || sft$fitIndices[which(powers == power), "SFT.R.sq"] < R2cut) {
    # fallback to highest R²
    idx <- which.max(sft$fitIndices[, "SFT.R.sq"])
    power <- powers[idx]
    message("Fallback power = ", power)
  }
  list(power = power, fitIndices = sft$fitIndices)
}

#' Plot scale-free fit and mean connectivity
#'
#' @param fitIndices from pickSoftThreshold()
plotSoftPower <- function(fitIndices) {
  par(mfrow = c(1, 2))
  plot(fitIndices[, 1], fitIndices[, 2],
       xlab = "Soft Threshold (power)", ylab = "Scale Free R²",
       type = "b", main = "Scale Free Fit")
  plot(fitIndices[, 1], fitIndices[, 5],
       xlab = "Soft Threshold (power)", ylab = "Mean Connectivity",
       type = "b", main = "Mean Connectivity")
  par(mfrow = c(1, 1))
}
