require(testthat)
context("patch")

test_that("the is_patch function works", {

  p1 <- patch_identity()
  expect_true(is_patch(p1))

  p2 <- patch_identity()

  p <- purrr::compose(p2, p1)
  expect_false(is_patch(p, allow_composed = FALSE))
  expect_true(is_patch(p, allow_composed = TRUE))

  p3 <- patch_identity()
  p2 <- purrr::compose(p3, p2)
  p <- purrr::compose(p2, p1)

  expect_false(is_patch(p, allow_composed = FALSE))
  expect_true(is_patch(p, allow_composed = TRUE))
})

test_that("the patch_type function works", {

  p <- patch_identity()
  expect_identical(patch_type(p), "identity")
  expect_identical(patch_type(p, short = FALSE), "patch_identity")

  p1 <- patch_shift(1L, shift = 1)
  expect_identical(patch_type(p1), "shift")

  p2 <- patch_scale(1L, scale_factor = 2)
  expect_identical(patch_type(p2), "scale")

  p <- purrr::compose(p2, p1)
  expect_identical(patch_type(p), c("shift", "scale"))
})


test_that("the get_patch_params function works", {

  p1 <- patch_shift(1L, shift = 1)

  result <- get_patch_params(p1)
  expect_true(is.list(result))
  expect_identical(result, expected = list("cols"=1L, "shift"=1))

  p2 <- patch_scale(1L, scale_factor = 2)
  p <- purrr::compose(p2, p1)

  expect_false(is_patch(p, allow_composed = FALSE))
  expect_true(is_patch(p, allow_composed = TRUE))

  result <- get_patch_params(p)
  expect_true(is.list(result))
  expect_equal(length(result), 2)

  expect_true(is.list(result[[1]]))
  expect_identical(result[[1]], expected = list("cols"=1L, "shift"=1))

  expect_true(is.list(result[[2]]))
  expect_identical(result[[2]], expected = list("cols"=1L, "scale_factor"=2))
})