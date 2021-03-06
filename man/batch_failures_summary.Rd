% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/batch_failures_summary.R
\name{batch_failures_summary}
\alias{batch_failures_summary}
\title{Summarise the failures in a batch of synthetic experiments}
\usage{
batch_failures_summary(batch_output)
}
\arguments{
\item{batch_output}{A list of lists of executed \code{synthetic_experiment} objects, as returned
by the \code{batch_experiment} function.}
}
\description{
Prints to the console a summary of failed experiments in a batch.
}
\examples{
\dontrun{
data_ids <- c("cars")
corruptions <- list(sample_patch_identity,
                   sample_patch_permute,
                   sample_patch_delete,
                   list(sample_patch_insert, sample_patch_permute))
batch_output <- batch_experiment(data_ids, corruptions = corruptions, N = 2,
                   data_reader = get)
# Experiment 3 failed because the 'cars' dataset has only two columns.
batch_failures_summary(batch_output)
}
}
\seealso{
\code{\link{batch_experiment}}
}
