context("Data preprocessing")

test_that("loadExpressionData reads a small CSV correctly", {
  # create temp file
  tmp <- tempfile(fileext = ".csv")
  write.csv(data.frame(Sample1 = 1:3, Sample2 = c(2,4,6)),
            row.names = c("GeneA","GeneB","GeneC"),
            file = tmp)
  expr <- loadExpressionData(tmp, sep = ",", row.names = 1)
  expect_true(is.matrix(expr))
  expect_equal(rownames(expr), c("GeneA","GeneB","GeneC"))
  expect_equal(colnames(expr), c("Sample1","Sample2"))
  file.remove(tmp)
})

test_that("filterGenesByVariance retains top N genes", {
  mat <- matrix(1:20, nrow = 5)
  rownames(mat) <- paste0("G",1:5)
  # variances are increasing across rows
  filtered <- filterGenesByVariance(mat, topN = 3)
  expect_equal(nrow(filtered), 3)
  expect_equal(rownames(filtered), c("G5","G4","G3"))
})

test_that("normalizeExpression on log2 produces no NAs", {
  mat <- matrix(c(0,1,4,9), nrow = 2)
  norm <- normalizeExpression(mat, method = "log2")
  expect_false(any(is.na(norm)))
  expect_equal(norm[1,1], log2(0+1))
})

