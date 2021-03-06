% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/diffness.R
\name{diffness.factor}
\alias{diffness.factor}
\title{Compute the mismatch between two vectors of unordered categorical data}
\usage{
\method{diffness}{factor}(x, y, diff = tv, ...)
}
\arguments{
\item{x, y}{A pair of unordered factors. If \code{y} is not already a factor it is
converted to one, unless it contains continuous numerical data, in which case
the mismatch is always 1.}

\item{diff}{Mismatch method. The default is \code{tv} (total variation distance) for
unordered categorical data.}

\item{...}{Additional arguments are ignored.}
}
\description{
Compute the mismatch between two vectors of unordered categorical data
}
\keyword{internal}
