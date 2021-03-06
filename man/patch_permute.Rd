% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/patch_permute.R
\name{patch_permute}
\alias{patch_permute}
\title{\code{patch_permute} S3 class constructor}
\usage{
patch_permute(perm)
}
\arguments{
\item{perm}{A vector of integers, being a permutation of 1..n, where n is the
number of columns in the dataset}
}
\value{
A \code{patch_permute} object. When applied to a data set with columns
    \eqn{a_1, a_2, ..., a_n}, the result is a dataset with columns
    \eqn{a_{\mbox{perm}[1]}, a_{\mbox{perm}[2]}, ..., a_{\mbox{perm}[n]}}
}
\description{
S3 class \code{patch_permute} which extends the \code{patch} and
\code{function} classes to represent a transformation of a tabular dataset
by an arbitrary permutation of the column indices.
}
\examples{
head(mtcars)
p <- patch_permute(c(2L, 3L, 1L, 4:ncol(mtcars)))

head(apply_patch(mtcars, p))

# Attempting to apply a patch to an incompatible data frame throws an error.
\dontrun{
p <- patch_permute(1:(ncol(mtcars) + 1))
p(mtcars)
}
}
\seealso{
\code{\link{is_valid_columns}} \code{\link{is_compatible_columns}}
}
