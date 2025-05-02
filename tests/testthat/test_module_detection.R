context("Module detection and merging")

test_that("detectModules identifies at least one module", {
  # small toy TOM: block diagonal to force two modules
  tom <- diag(10)
  tom[1:5,1:5] <- tom[1:5,1:5] + 1
  tom[6:10,6:10] <- tom[6:10,6:10] + 1
  dissTOM <- 1 - tom
  res <- detectModules(dissTOM, deepSplit = 1, minModuleSize = 2)
  expect_true(is.list(res))
  expect_true("moduleColors" %in% names(res))
  uniqueColors <- unique(res$moduleColors)
  expect_true(length(uniqueColors) >= 2)
})

test_that("mergeModules merges correctly when multiple modules", {
  # simulate expr for merging test: 6 samples × 6 genes
  mat <- matrix(rnorm(36), nrow = 6, ncol = 6)
  datExpr <- mat
  # create two modules: first 3 genes and last 3 genes
  colors <- c(rep("blue",3), rep("red",3))
  merged <- mergeModules(datExpr, colors, cutHeight = 0.5)
  expect_true(is.list(merged))
  expect_true("mergedColors" %in% names(merged))
  expect_equal(length(merged$mergedColors), 6)
})
