#' Compute the mismatch between two datasets
#'
#' \code{diffness} is a generic function: the type of the first argument
#' determines which method is called.
#'
#' @param x,y
#' A pair of datasets
#' @param ...
#' Additional arguments passed to methods.
#'
#' @return A non-negative number quantifying the mismatch between the two
#' datasets.
#'
#' @export
diffness <- function(x, y, ...) UseMethod("diffness")

#' Compute the mismatch between two data frames
#'
#' @param x,y
#' A pair of datasets
#' @param col_diff
#' A numeric scalar specifying the additional mismatch per column when \code{x}
#' and \code{y} have different numbers of columns. Defaults to 1.
#' @param ...
#' Additional arguments passed to methods.
#'
#' @export
diffness.data.frame <- function(x, y, col_diff = 1, ...) {

  stopifnot(is.data.frame(y))
  stopifnot(length(x) > 0 && length(y) > 0)

  if (length(x) != length(y)) {
    stopifnot(is.numeric(col_diff) && length(col_diff) == 1)
    n <- min(length(x), length(y))
    m <- max(length(x), length(y))
    return(diffness(x[1:n], y[1:n]) + col_diff * (m - n))
  }

  sum(map2_dbl(x, y, diffness))
}

# NOTE: numeric is equivalent to (double OR integer). Since we want to exclude
# integer (i.e. treat that case as discrete) it makes sense to have
# diffness.integer & diffness.double, and omit diffness.numeric.

#' Compute the mismatch between two continuous numeric vectors
#'
#' @param x,y
#' A pair of vectors of type \code{double}.
#' @param diff
#' Mismatch method. The default is \code{ks} (Kolmogorov-Smirnov) for continuous
#' numeric data.
#' @param ...
#' Additional arguments are ignored.
#'
#' @export
diffness.double <- function(x, y, diff = ks, ...) {
  stopifnot(is.vector(y))

  if (!is.double(y))
    return(1.0)
  diff(x, y)
}

#' Compute the mismatch between two integer vectors
#'
#' Integer vectors are treated as ordered categorical data, so the mismatch
#' between an integer vector and a non-integer numeric vector is always 1.
#'
#' @param x,y
#' A pair of vectors of type \code{integer}.
#' @param diff
#' Mismatch method. The default is \code{ks} (Kolmogorov-Smirnov) for integer
#' data.
#' @param ...
#' Additional arguments are ignored.
#'
#' @export
diffness.integer <- function(x, y, diff = ks, ...) {
  stopifnot(is.vector(y))

  if (!is.integer(y))
    return(1.0)

  # IMP TODO NEXT: what happens if diff is set to another function? (e.g. tv)

  # Note that two equivalent implementations are possible:
  # 1. call diff directly (i.e. treat integers as numeric).
  # 2. call diffness(as.ordered(x), as.ordered(y), diff = diff), thereby
  # explicitly treating integers as ordered categorical data.
  # Since the results are identical we take the simplest route.
  diff(x, y)
}

#' Compute the mismatch between two vectors of ordered categorical data
#'
#' @param x,y
#' A pair of ordered factors.
#' @param diff
#' Mismatch method. The default is \code{ks} (Kolmogorov-Smirnov) for ordered
#' categorical data.
#' @param ...
#' Additional arguments are ignored.
#'
#' @export
diffness.ordered <- function(x, y, diff = ks, ...) {
  stopifnot(is.factor(y))

  # Ordered discrete data are, by default, compared using ks, rather
  # than tv (although both make sense), since this takes into account the
  # separation implied by the ordering. See test-diffness.R.

  # Note: in contrast to other diffness methods, we do not test that y is
  # ordered (and return 1.0 if not) as this might give unexpected results
  # (and ks will give an error in that case).
  diff(x, y)
}
0
#' Compute the mismatch between two vectors of unordered categorical data
#'
#' @param x,y
#' A pair of unordered factors.
#' @param diff
#' Mismatch method. The default is \code{tv} (total variation distance) for
#' unordered categorical data.
#' @param ...
#' Additional arguments are ignored.
#'
#' @export
diffness.factor <- function(x, y, diff = tv, ...) {
  stopifnot(is.factor(y))

  if (!is.factor(y))
    return(1.0)
  diff(x, y)
}

#' Compute the mismatch between two character vectors
#'
#' Character vectors are treated as unordered categorical data.
#'
#' @param x,y
#' A pair of vectors of type \code{character}.
#' @param diff
#' Mismatch method. The default is \code{tv} (total variation distance) for
#' unordered categorical data.
#' @param ...
#' Additional arguments are ignored.
#'
#' @export
diffness.character <- function(x, y, diff = tv, ...) {
  stopifnot(is.vector(y))

  if (!is.character(y))
    return(1.0)
  diffness(as.factor(x), as.factor(y), diff = diff)
}

#' Compute the mismatch between two logical vectors
#'
#' Logical vectors are treated as unordered categorical data.
#'
#' @param x,y
#' A pair of vectors of type \code{logical}.
#' @param diff
#' Mismatch method. The default is \code{tv} (total variation distance) for
#' unordered categorical data.
#' @param ...
#' Additional arguments are ignored.
#'
#' @export
diffness.logical <- function(x, y, diff = tv, ...) {
  stopifnot(is.vector(y))

  if (!is.logical(y))
    return(1.0)
  diffness(as.factor(x), as.factor(y), diff = diff)
}


# TPH: Since the following functions aren't implementations of a generic
# function, the type of v1 is not known, but is assumed. For this reason
# I've moved the logic to the preceding generic methods.

## ----------------------------------------------------------------------------
## These functions compute the diffness for different types.

# diffness_continuous <- function(v1, v2, diff = ks) {
#   if (!is_continuous(v2)) return(1.0)
#
#   diff(v1, v2)
# }
#
# diffness_ordered <- function(v1, v2, diff = ks) {
#   if (!is_ordered(v2)) return(1.0)
#   stop("Not implemented yet")
# }
#
# diffness_categorical <- function(v1, v2, diff = tv) {
#   if (!is_categorical(v2)) return(1.0)
#
#   diff(v1, v2)
# }