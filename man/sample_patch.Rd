% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sample_patch.R
\name{sample_patch}
\alias{sample_patch}
\title{Randomly sample a composed patch}
\usage{
sample_patch(df, ..., column_param = "cols",
  exclude_cols_arg = "exclude_cols")
}
\arguments{
\item{df}{A data frame}

\item{...}{n patch sampler functions to apply in order from right to left.}

\item{column_param}{The name of the column index parameter in column-wise patch types, used to
ensure column-wise uniqueness of the sampled patch. Defaults to \code{cols}.}

\item{exclude_cols_arg}{The name of the argument, in the given patch samplers for column-wise patch
types, used to exclude particular column indices from selection when sampling.
Used to ensure column-wise uniqueness of the sampled patch. Defaults to
\code{exclude_cols}.}
}
\description{
Randomly sample a composed patch
}
\examples{
p <- sample_patch(mtcars, sample_patch_delete, sample_patch_permute)
p
head(p(mtcars))

}
