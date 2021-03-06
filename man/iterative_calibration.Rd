% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/iterative_calibration.R
\name{iterative_calibration}
\alias{iterative_calibration}
\title{Calibrate penalty parameters by iterative bootstrapping}
\usage{
iterative_calibration(data_ids, datadiff = ddiff,
  patch_generators = list(gen_patch_rescale, gen_patch_recode),
  patch_penalties = c(0.4, 0.4), permute_penalty = 0.1,
  break_penalty = 0.95, N = 10, M = 10, split = 0.5,
  hyperseed = sample.int(.Machine$integer.max, size = 1),
  data_reader = get, target_fpr = 0.05, acceptance_margin = 0.1,
  increment_factor = 1.2, decrement_factor = 0.8,
  lower_boundary = 10^(-6), upper_boundary = 1 - lower_boundary,
  check_viability = TRUE, pb = TRUE, logfile = NULL)
}
\arguments{
\item{data_ids}{A character vector of data frame identifiers. Each one must be a valid
\code{data_id} input to \code{\link{configure_synthetic_experiment}}.}

\item{datadiff}{The datadiff function for the experiment.}

\item{patch_generators}{A list of patch generator functions from which candidate patches will be generated.}

\item{patch_penalties}{A numeric vector of patch penalties corresponding to the \code{patch_generators}
list. The lengths of these two arguments must be equal.}

\item{permute_penalty}{The penalty associated with a permutation patch.}

\item{break_penalty}{The penalty associated with a break patch.}

\item{N}{The number of experiments (i.e. random splits of the data) per random seed.}

\item{M}{The number of random seeds to be sampled from the \code{hyperseed}.}

\item{split}{A number in the unit interval specifying the splitting ratio.}

\item{hyperseed}{A random seed used to select the \code{M} seeds for each corruption. By
default an integer seed is chosen at random.}

\item{data_reader}{A function which reads the data, given each of the arguments in \code{data_id}.}

\item{target_fpr}{The target false positive rate.}

\item{acceptance_margin}{The acceptable margin around the target false positive rate.}

\item{increment_factor}{The factor by which penalties are incremented between iterations.}

\item{decrement_factor}{The factor by which penalties are decremented between iterations.}

\item{lower_boundary}{The lower boundary which determines the domain for patch penalty values.}

\item{upper_boundary}{The lower boundary which determines the domain for patch penalty values.}

\item{check_viability}{A logical flag. If \code{TRUE} (the default) a preliminary viability run will
be executed with all penalties set to their lower boundary values. The
calibration procedure is valid for a given patch type if the false positive
rate for that type is inside or above the acceptance interval when the
penalty takes the \code{lower_boundary} value.}

\item{pb}{A logical flag. If \code{TRUE} (the default) a progress bar will be
displayed in the console.}

\item{logfile}{(Optional) The full path to a logfile.}
}
\value{
A named numeric vector.
}
\description{
Calibrate penalty parameters by iterative bootstrapping
}
