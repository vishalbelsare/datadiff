% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/patch_insert.R
\name{patch_insert}
\alias{patch_insert}
\title{\code{patch_insert} S3 class constructor}
\usage{
patch_insert(insertion_point, data)
}
\arguments{
\item{insertion_point}{A scalar column identifier. The new columns will be inserted immediately
after this column.}

\item{data}{A data frame containing the new column data.}
}
\value{
A \code{patch_insert} object.
}
\description{
S3 class \code{patch_insert} which extends the \code{patch} and
\code{function} classes to represent a transformation of a tabular dataset
by inserting one or more new columns.

When applied to a data frame, a \code{patch_insert} calls the
\code{dplyr::bind_cols} function to produce its result. As such, it is that
function which determines how column name conflicts are handled. As of
\code{dplyr} v0.7, this is done with a call to \code{tibble::repair_names}.
}
\examples{
head(mtcars)
p <- patch_insert("gear", data = mtcars[2:4])
p <- patch_insert(0L, data = mtcars[2:4])

# The following are equivalent:
head(apply_patch(mtcars, p))
head(p(mtcars))

# Attempting to apply a patch to an incompatible data frame throws an error.
\dontrun{
p <- patch_insert(22L, data = mtcars[2:4])
p(mtcars)
}
}
\seealso{
\code{\link{is_valid_columns}} \code{\link{is_compatible_columns}}
}
