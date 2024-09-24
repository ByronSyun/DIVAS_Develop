#' Calculate the Median of the Marčenko-Pastur Distribution
#'
#' This function estimates the median of the Marčenko-Pastur distribution given a ratio parameter \code{beta}.
#' The Marčenko-Pastur distribution describes the asymptotic behavior of eigenvalues of large random matrices
#' and is widely used in random matrix theory and statistics for noise estimation and signal processing.
#'
#' @param beta A numeric value between 0 and 1 representing the aspect ratio of the matrix (\code{n/d}),
#' where \code{n} is the number of columns and \code{d} is the number of rows.
#' This ratio defines the shape of the Marčenko-Pastur distribution.
#'
#' @return A numeric value representing the estimated median of the Marčenko-Pastur distribution.
#'
#' @details The function iteratively narrows down the interval containing the median of the Marčenko-Pastur
#' distribution by evaluating the distribution function until the interval is sufficiently small.
#' The bounds of the distribution are defined by \code{(1 - sqrt(beta))^2} and \code{(1 + sqrt(beta))^2}.
#'
MedianMarcenkoPastur <- function(beta) {
  MarPas <- function(x) 1 - incMarPas(x, beta, 0)
  lobnd <- (1 - sqrt(beta))^2
  hibnd <- (1 + sqrt(beta))^2
  change <- TRUE

  while (change && (hibnd - lobnd > 0.001)) {
    change <- FALSE
    x <- seq(lobnd, hibnd, length.out = 5)
    y <- sapply(x, MarPas)

    if (any(y < 0.5)) {
      lobnd <- max(x[y < 0.5])
      change <- TRUE
    }
    if (any(y > 0.5)) {
      hibnd <- min(x[y > 0.5])
      change <- TRUE
    }
  }

  med <- (hibnd + lobnd) / 2
  return(med)
}
