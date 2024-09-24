#' Optimal Shrinkage of Singular Values
#'
#' Performs optimal shrinkage of singular values according to a specified loss function, given the shape parameter \code{beta} and noise level \code{sigma}.
#' This function adjusts the singular values of a matrix to reduce noise and enhance signal components based on the Marčenko-Pastur distribution.
#'
#' @param singvals A numeric vector of singular values to be shrunk.
#' @param beta A numeric value between 0 and 1 representing the aspect ratio of the matrix (\code{n/d}), where \code{n} is the number of columns and \code{d} is the number of rows.
#' @param loss A character string specifying the type of loss function to use for shrinkage. Must be one of \code{"fro"} (Frobenius norm), \code{"op"} (Operator norm), or \code{"nuc"} (Nuclear norm).
#' @param sigma A positive numeric value representing the noise level to be used in the shrinkage process.
#'
#' @return A numeric vector of shrunk singular values.
#'
#' @details The function applies different shrinkage strategies based on the specified loss function:
#' \describe{
#'   \item{\code{"fro"}}{Uses Frobenius norm shrinkage, which minimizes the mean squared error.}
#'   \item{\code{"op"}}{Uses Operator norm shrinkage, which targets the largest singular value.}
#'   \item{\code{"nuc"}}{Uses Nuclear norm shrinkage, which adjusts the sum of singular values while penalizing those close to zero.}
#' }
#'
#' Internal helper functions are used to compute the adjusted singular values according to the specified loss type:
#' \describe{
#'   \item{\code{opt_fro_shrink}}{Calculates shrinkage based on the Frobenius norm.}
#'   \item{\code{opt_op_shrink}}{Calculates shrinkage based on the Operator norm.}
#'   \item{\code{opt_nuc_shrink}}{Calculates shrinkage based on the Nuclear norm.}
#' }
#'
optshrink_impl <- function(singvals, beta, loss, sigma) {
  stopifnot(sigma > 0)

  # internal functions for shrinkage as per the loss type
  x <- function(y) {
    sqrt(0.5 * pmax((y^2 - beta - 1) + sqrt(pmax((y^2 - beta - 1)^2 - 4 * beta, 0)), 0)) *
      (y >= 1 + sqrt(beta))
  }

  opt_fro_shrink <- function(y) {
    sqrt(pmax(((y^2 - beta - 1)^2 - 4 * beta), 0)) / y
  }

  opt_op_shrink <- function(y) {
    pmax(x(y), 0)
  }

  opt_nuc_shrink <- function(y) {
    pmax(0, (x(y)^4 - sqrt(beta) * x(y) * y - beta) / ((x(y)^2) * y))
  }

  # Apply the shrinkage based on the loss function
  if (loss == "fro") {
    singvals <- sigma * opt_fro_shrink(singvals / sigma)
  } else if (loss == "nuc") {
    y <- singvals / sigma
    singvals <- sigma * opt_nuc_shrink(y)
    singvals[x(y)^4 - sqrt(beta) * x(y) * y - beta <= 0] <- 0
  } else if (loss == "op") {
    singvals <- sigma * opt_op_shrink(singvals / sigma)
  } else {
    stop("Unknown loss function specified.")
  }

  return(singvals)
}
