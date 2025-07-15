context("Soft-threshold power selection")

test_that("pickSoftPower returns valid power and fitIndices", {
  # simulate small expr: 10 samples × 50 genes
  set.seed(1)
  dat <- matrix(rnorm(500), nrow = 10, ncol = 50)
  rownames(dat) <- paste0("S",1:10)
  colnames(dat) <- paste0("G",1:50)
  res <- pickSoftPower(dat, powers = 1:5, networkType = "unsigned", corType = "pearson", R2cut = 0)
  expect_true(is.list(res))
  expect_true("power" %in% names(res))
  expect_true(res$power %in% 1:5)
  expect_true(is.matrix(res$fitIndices))
  expect_equal(ncol(res$fitIndices) >= 5, TRUE)
})
