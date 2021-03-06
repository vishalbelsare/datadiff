require(testthat)
context("ddiff")

test_that("the ddiff function works", {

  generate_normal_df <- function(n) {
    v1 <- rnorm(n)
    v2 <- rnorm(n, sd = 4)
    v3 <- rnorm(n, mean = 2)
    v4 <- rnorm(n, sd = 2, mean = 4)
    v5 <- rnorm(n, sd = 4, mean = 8)
    data.frame("v1" = v1, "v2" = v2, "v3" = v3, "v4" = v4, "v5" = v5)
  }

  set.seed(22)
  df1 <- generate_normal_df(100)
  df2 <- generate_normal_df(101)

  patch_generators = list(gen_patch_affine, gen_patch_recode)
  penalty_scaling <- purrr::partial(ks_scaling, nx = nrow(df1),
                                    ny = nrow(df2))

  result <- ddiff(df1, df2 = df2, patch_generators = patch_generators,
                  patch_penalties = c(0.6, 0.6), break_penalty = 0.99,
                  permute_penalty = 0.1, penalty_scaling = penalty_scaling)
  expect_true(is_patch(result, allow_composed = FALSE))
  expect_equal(patch_type(result), "identity")

  perm <- as.integer(c(2, 3, 1, 4, 5))

  # Note that in this case, due to the similarity between v1 and the shifted v3,
  # we must take a large transform patch penalty and a small permute penalty.
  # Q: why do we not see this in the alternative (original) algorithm?
  patch_penalties <- c(0.7, 0.7)
  result <- ddiff(df1, df2 = df2[perm], patch_generators = patch_generators,
                  patch_penalties = patch_penalties, break_penalty = 0.99,
                  permute_penalty = 0.1, penalty_scaling = penalty_scaling)
  expect_equal(patch_type(result), "permute")
  expect_identical(get_patch_params(result)[["perm"]], expected = perm)

  ## Test with an affine transformation.
  set.seed(22)
  df1 <- generate_normal_df(100)
  df2 <- generate_normal_df(101)

  df2[[1]] <- 32 + (9/5) * df2[[1]]

  result <- ddiff(df1, df2 = df2, patch_generators = patch_generators,
                  patch_penalties = c(0.6, 0.6), break_penalty = 0.99,
                  permute_penalty = 0.1, penalty_scaling = penalty_scaling,
                  as.list = TRUE)

  # Affine transform is correctly identified, with (approximately) correct
  # parameters.
  expect_equal(length(result), expected = 2)
  expect_equal(patch_type(result[[1]]), expected = "scale")
  expect_equal(get_patch_params(result[[1]])[["cols"]], expected = 1)
  expect_equal(get_patch_params(result[[1]])[["scale_factor"]], expected = 2,
               tolerance = 0.1)
  expect_equal(patch_type(result[[2]]), "shift")
  expect_equal(get_patch_params(result[[2]])[["cols"]], expected = 1)
  expect_equal(get_patch_params(result[[2]])[["shift"]], expected = 32,
               tolerance = 0.01)

  ## Repeat the affine test with more difficult parameters...
  set.seed(22)
  df1 <- generate_normal_df(100)
  df2 <- generate_normal_df(101)

  df2[[1]] <- 2 + (7/5) * df2[[1]]

  result <- ddiff(df1, df2 = df2, patch_generators = patch_generators,
                  patch_penalties = c(0.6, 0.6), break_penalty = 0.99,
                  permute_penalty = 0.1, penalty_scaling = penalty_scaling,
                  as.list = TRUE)

  # ...still works.
  expect_equal(length(result), expected = 2)
  expect_equal(patch_type(result[[1]]), expected = "scale")
  expect_equal(get_patch_params(result[[1]])[["cols"]], expected = 1)
  expect_equal(get_patch_params(result[[1]])[["scale_factor"]], expected = 2,
               tolerance = 0.3)
  expect_equal(patch_type(result[[2]]), "shift")
  expect_equal(get_patch_params(result[[2]])[["cols"]], expected = 1)
  expect_equal(get_patch_params(result[[2]])[["shift"]], expected = 2,
               tolerance = 0.02)

  ## Repeat again with even more difficult parameters...
  set.seed(22)
  df1 <- generate_normal_df(100)
  df2 <- generate_normal_df(101)

  df2[[1]] <- 2 + (6/5) * df2[[1]]

  result <- ddiff(df1, df2 = df2, patch_generators = patch_generators,
                  patch_penalties = c(0.6, 0.6), break_penalty = 0.99,
                  permute_penalty = 0.1, penalty_scaling = penalty_scaling,
                  as.list = TRUE)

  # ...still works.
  expect_equal(length(result), expected = 2)
  expect_equal(patch_type(result[[1]]), expected = "scale")
  expect_equal(patch_type(result[[2]]), expected = "shift")

  ## Test with differing numbers of columns.
  set.seed(22)
  df1 <- generate_normal_df(100)
  df2 <- generate_normal_df(101)

  cols <- c(1:2, 4)

  result <- ddiff(df1, df2 = df2[cols], patch_generators = patch_generators,
                  patch_penalties = c(0.6, 0.6), break_penalty = 0.99,
                  permute_penalty = 0.1, penalty_scaling = penalty_scaling)
  expect_true(is_patch(result, allow_composed = TRUE))
  expect_equal(length(decompose_patch(result)), expected = 2)
  expect_equal(patch_type(decompose_patch(result)[[1]]), "delete")
  expect_identical(get_patch_params(decompose_patch(result)[[1]])[["cols"]],
                   expected = 5L)
  expect_equal(patch_type(decompose_patch(result)[[2]]), "delete")
  expect_identical(get_patch_params(decompose_patch(result)[[2]])[["cols"]],
                   expected = 3L)
  expect_identical(names(result(df1)), expected = names(df2[cols]))

  ## Test with a permutation only (but with differing numbers of columns)
  perm <- as.integer(c(2, 5, 1, 4, 3))

  result <- ddiff(df1, df2 = df2[perm][cols], patch_generators = patch_generators,
                  patch_penalties = c(0.6, 0.6), break_penalty = 0.99,
                  permute_penalty = 0.1, penalty_scaling = penalty_scaling)
  expect_true(is_patch(result, allow_composed = TRUE))

  expect_identical(names(result(df1)), expected = names(df2[perm][cols]))

  # Note: very high patch_penalty required here for correct identification of the
  # permutation.
  insert_col_prefix <- "INSERT."
  result <- ddiff(df1[cols], df2 = df2[perm], patch_generators = patch_generators,
                  patch_penalties = c(0.8, 0.8), break_penalty = 0.99,
                  permute_penalty = 0.1, penalty_scaling = penalty_scaling,
                  insert_col_prefix = insert_col_prefix)
  expect_true(is_patch(result, allow_composed = TRUE))

  expected <- names(df2[perm])
  inserted_cols <- which(expected %in% paste0("v", setdiff(1:5, cols)))
  expected[inserted_cols] <- paste0(insert_col_prefix, expected[inserted_cols])
  expect_identical(names(result(df1[cols])), expected = expected)

  #### Test with mixed data types.

  generate_mixed_df <- function(n = 100) {
    v1 <- rnorm(n)
    v2 <- rnorm(n, sd = 4, mean = 1)
    v3 <- rexp(n)
    v4 <- sample.int(10, size = n, replace = TRUE)
    v5 <- sample(c("M", "F"), size = n, replace = TRUE, prob = c(1/4, 3/4))
    data.frame("v1" = v1, "v2" = v2, "v3" = v3, "v4" = v4, "v5" = v5,
               stringsAsFactors = FALSE)
  }

  set.seed(22)
  df1 <- generate_mixed_df(100)
  df2 <- generate_mixed_df(101)

  result <- ddiff(df1, df2 = df2, patch_generators = patch_generators,
                  patch_penalties = c(0.6, 0.6), break_penalty = 0.99,
                  permute_penalty = 0.1, penalty_scaling = penalty_scaling)

  expect_true(is_patch(result, allow_composed = FALSE))
  expect_equal(patch_type(result), "identity")

  # Reducing the penalty associated with a transformation patch changes the
  # result: the cost of an affine patch becomes less than improvement in mismatch.
  result <- ddiff(df1, df2 = df2, patch_generators = patch_generators,
                  patch_penalties = c(0.4, 0.4), break_penalty = 0.99,
                  permute_penalty = 0.1, penalty_scaling = penalty_scaling)

  expect_true(is_patch(result, allow_composed = TRUE))
  expect_false(is_patch(result, allow_composed = FALSE))

  ## Test with a shift.
  set.seed(22)
  df1 <- generate_mixed_df(100)
  df2 <- generate_mixed_df(100)
  df2[[1]] <- 4 + df2[[1]]

  result <- ddiff(df1, df2 = df2, patch_generators = patch_generators,
                  patch_penalties = c(0.6, 0.6), break_penalty = 0.99,
                  permute_penalty = 0.1, penalty_scaling = penalty_scaling,
                  as.list = TRUE)

  # Test for the expected result.
  expect_equal(length(result), 2)
  expect_equal(patch_type(result[[1]]), "scale")
  expect_equal(patch_type(result[[2]]), "shift")

  ## Test with the numeric columns permuted in df1 and a shift.
  set.seed(22)
  df1 <- generate_mixed_df(100)
  df2 <- generate_mixed_df(101)
  df2[[1]] <- 4 + df2[[1]]
  perm <- as.integer(c(2, 3, 1, 4, 5))
  df2 <- df2[perm]

  # Note: very high break penalty required for correct identification here.
  result <- ddiff(df1, df2 = df2, patch_generators = patch_generators,
                  patch_penalties = c(0.6, 0.6), break_penalty = 0.9999,
                  permute_penalty = 0.1, penalty_scaling = penalty_scaling,
                  as.list = TRUE)

  # Test for the expected result.
  expect_equal(length(result), 3)
  expect_equal(patch_type(result[[1]]), "scale")
  expect_equal(patch_type(result[[2]]), "shift")
  expect_equal(patch_type(result[[3]]), "permute")
  expect_equal(get_patch_params(result[[3]])[["perm"]], perm)

  ## Test with recodings of categorical data.
  set.seed(22)
  df1 <- generate_mixed_df(100)
  df2 <- generate_mixed_df(101)

  df2[[5]] <- ifelse(df2[[5]] == "M", yes = 1L, no = 0L)

  result <- ddiff(df1, df2 = df2, patch_generators = patch_generators,
                  patch_penalties = c(0.6, 0.6), break_penalty = 0.99,
                  permute_penalty = 0.1, penalty_scaling = penalty_scaling)

  expect_true(is_patch(result, allow_composed = FALSE))
  expect_identical(patch_type(result, short = TRUE), expected = "recode")
  expect_identical(get_patch_params(result)[["encoding"]],
                   expected = c("F" = 0L, "M" = 1L))

  perm <- as.integer(c(2, 3, 1, 4, 5))
  df2 <- df2[perm]

  result <- ddiff(df1, df2 = df2, patch_generators = patch_generators,
                  patch_penalties = c(0.6, 0.6), break_penalty = 0.99,
                  permute_penalty = 0.1, penalty_scaling = penalty_scaling,
                  as.list = TRUE)

  expect_equal(length(result), expected = 2)
  expect_identical(patch_type(result[[1]], short = TRUE),
                   expected = "recode")
  expect_identical(get_patch_params(result[[1]])[["encoding"]],
                   expected = c("F" = 0L, "M" = 1L))

  expect_identical(patch_type(result[[2]], short = TRUE),
                   expected = "permute")
  expect_identical(get_patch_params(result[[2]])[["perm"]],
                   expected = perm)


  #### Test the ignore_cols argument.
  set.seed(14722)
  df1 <- generate_mixed_df(500)
  df2 <- generate_mixed_df(501)

  df2[[1]] <- 100 + (5 * df2[[1]])
  perm <- as.integer(c(1, 3, 2, 4, 5))
  df2 <- df2[perm]

  patch_generators = list(gen_patch_rescale, gen_patch_recode)

  result <- ddiff(df1, df2 = df2, patch_generators = patch_generators,
                  patch_penalties = c(0.6, 0.6), break_penalty = 0.99,
                  permute_penalty = 0.1, penalty_scaling = penalty_scaling)

  expect_equal(length(decompose_patch(result)), expected = 2)
  expect_identical(patch_type(decompose_patch(result)[[1]], short = TRUE),
                   expected = "rescale")
  expect_identical(patch_type(decompose_patch(result)[[2]], short = TRUE),
                   expected = "permute")

  ignore_cols <- 1L
  result <- ddiff(df1, df2 = df2, patch_generators = patch_generators,
                  patch_penalties = c(0.6, 0.6), break_penalty = 0.99,
                  permute_penalty = 0.1, penalty_scaling = penalty_scaling,
                  ignore_cols = ignore_cols)

  expect_equal(length(decompose_patch(result)), expected = 1)
  expect_identical(patch_type(decompose_patch(result)[[1]], short = TRUE),
                   expected = "permute")
  expect_identical(get_patch_params(decompose_patch(result)[[1]])[["perm"]],
                   expected = perm)

  ignore_cols <- c(1L, 4L)
  result <- ddiff(df1, df2 = df2, patch_generators = patch_generators,
                  patch_penalties = c(0.6, 0.6), break_penalty = 0.99,
                  permute_penalty = 0.1, penalty_scaling = penalty_scaling,
                  ignore_cols = ignore_cols)

  expect_equal(length(decompose_patch(result)), expected = 1)
  expect_identical(patch_type(decompose_patch(result)[[1]], short = TRUE),
                   expected = "permute")
  expect_identical(get_patch_params(decompose_patch(result)[[1]])[["perm"]],
                   expected = perm)

  ignore_cols <- c(1L, 5L)
  result <- ddiff(df1, df2 = df2, patch_generators = patch_generators,
                  patch_penalties = c(0.6, 0.6), break_penalty = 0.99,
                  permute_penalty = 0.1, penalty_scaling = penalty_scaling,
                  ignore_cols = ignore_cols)

  expect_equal(length(decompose_patch(result)), expected = 1)
  expect_identical(patch_type(decompose_patch(result)[[1]], short = TRUE),
                   expected = "permute")
  expect_identical(get_patch_params(decompose_patch(result)[[1]])[["perm"]],
                   expected = perm)

  ignore_cols <- c(1L, 2L, 3L)
  result <- ddiff(df1, df2 = df2, patch_generators = patch_generators,
                  patch_penalties = c(0.6, 0.6), break_penalty = 0.99,
                  permute_penalty = 0.1, penalty_scaling = penalty_scaling,
                  ignore_cols = ignore_cols)

  expect_true(is_identity_patch(result))

  # TODO: test with data frames containing both factors and integer data (by
  # setting stringsAsFactors = TRUE above).

  # IMP TODO: test with (significantly) differing numbers of rows in df1 & df2.

})
