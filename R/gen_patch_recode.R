#' Generate a recode patch
#'
#' Generates a \code{patch_recode} object that minimises the mismatch between
#' the specified columns after application of the patch to \code{df1}.
#'
#' Note that the mismatch argument is ignored: the mismatch function is
#' \emph{always} taken to be \code{\link{tv}}, the total variation distance.
#'
#' @param df1
#' A data frame.
#' @param df2
#' A data frame.
#' @param mismatch
#' Mismatch method. Currently this argument is ignored and the mismatch function
#' is \emph{always} taken to be \code{\link{tv}}, the total variation distance.
#' @param col1
#' A column identifier (integer or string column name) with length 1.
#' @param col2
#' A column identifier (integer or string column name) with length 1. By default
#' this takes the value of \code{col1}.
#' @param allow_new_categories
#' A logical flag. If \code{FALSE}, the number of distinct categories in the
#' specified columns must be equal.
#' @param limit_int_categories
#' An integer specifying the limit on the number of categories above which
#' integer data shall no longer be considered categorical.
#'
#' @param ...
#' Additional arguments are ignored.
#'
#' @return A \code{patch_recode} object.
#'
#' @seealso \code{\link{patch_recode}}
#'
#' @export
#'
#' @examples
#' gen_patch_recode(esoph, esoph, col1 = "alcgp", col2 = "tobgp")
#'
gen_patch_recode <- function(df1, df2, mismatch = tv, col1, col2 = col1,
                             allow_new_categories = TRUE,
                             limit_int_categories = 2^5, ...) {

  stopifnot(is_compatible_columns(col1, df1) && length(col1) == 1)
  stopifnot(is_compatible_columns(col2, df2) && length(col2) == 1)

  v1 <- df1[[col1]]
  v2 <- df2[[col2]]

  stopifnot(sum(!is.na(v1)) != 0 && sum(!is.na(v2)) != 0)

  if (is.double(v1) || is.double(v2))
    stop("Encodings require categorical data")
  if (is.integer(v1) && length(unique(v1)) > limit_int_categories)
    stop("Encodings require categorical data: max integer categories exceeded")
  if (is.integer(v2) && length(unique(v2)) > limit_int_categories)
    stop("Encodings require categorical data: max integer categories exceeded")

  f1 <- as.factor(v1)
  f2 <- as.factor(v2)
  lev1 <- levels(f1)
  lev2 <- levels(f2)

  if (!allow_new_categories && length(lev2) != length(lev1))
    stop("Conflicting number of categories & allow_new_categories is FALSE")
  if (length(lev2) < length(lev1))
    stop("Insufficient target codes")

  ## TODO:
  # In the case of the default mismatch function (tv) we can compare possible
  # recodings in polynomial time by looking pairwise (i'th level in f1 is
  # recoded as j'th level in f2) and applying the Hungarian method.
  # For general mismatch function, the only obvious method is to try all
  # possible recodings, but that involves O(n!) operations, where n = length(lev1).
  # - Currently, therefore, we *assume* that mismatch is tv (or, equivalently,
  #   the default diffness).

  # In case the mismatch function is tv, use the Hungarian algorithm.
  t1 <- tabulate(f1)
  t2 <- tabulate(f2)
  x <- outer(t1, t2, FUN = purrr::compose(abs, `-`))

  # Apply the Hungarian algorithm to solve the assignment problem.
  soln <- clue::solve_LSAP(x, maximum = FALSE)

  # Convert the solution into a recode patch.
  encoding <- lev2[soln]
  if (!is.factor(v2))
    encoding <- methods::as(encoding, class(v2))
  names(encoding) <- lev1

  patch_recode(col1, encoding = encoding, one_to_one = TRUE)
}
