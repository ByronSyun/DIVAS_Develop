#' Incomplete Marčenko-Pastur Distribution Function
#'
#' Computes the incomplete Marčenko-Pastur distribution function, which is used in estimating noise levels.
#'
#' @param x0 A numeric value representing the lower limit of integration.
#' @param beta A numeric value indicating the ratio of columns to rows in the data matrix.
#' @param gamma A numeric value specifying the power to which the function should be raised during integration.
#'
#' @return A numeric value of the integrated Marčenko-Pastur function.
#'
incMarPas <- function(x0, beta, gamma) {
  topSpec <- (1 + sqrt(beta))^2
  botSpec <- (1 - sqrt(beta))^2

  MarPas <- function(x) {
    ifelse((topSpec - x) * (x - botSpec) > 0,
           sqrt(pmax((topSpec - x) * (x - botSpec), 0)) / (beta * x) / (2 * pi),
           0)
  }


  if (gamma != 0) {
    fun <- function(x) x^gamma * MarPas(x)
  } else {
    fun <- MarPas
  }

  I <- stats::integrate(fun, x0, topSpec)$value
  return(I)
}





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


#' Optimal Shrinkage Estimation using Kolmogorov-Smirnov Criterion
#'
#' This function estimates the optimal shrinkage parameter for singular values using the Kolmogorov-Smirnov (KS) criterion, which helps identify noise levels in high-dimensional data.
#'
#' @param singVals A numeric vector of singular values from a data matrix.
#' @param betaShrinkage A numeric value representing the aspect ratio of the data matrix (ratio of columns to rows or vice versa).
#'
#' @return A numeric value representing the estimated optimal noise level (sigma) based on the KS criterion.
ksOpt <- function(singVals, betaShrinkage) {
  sigmaMin <- stats::median(singVals) / (1 + sqrt(betaShrinkage))
  sigmaMax <- 2 * max(singVals) / (1 + sqrt(betaShrinkage))
  numGrid <- 200

  cands <- seq(sigmaMin, sigmaMax, length.out = numGrid)
  objVals <- numeric(numGrid)

  for (ii in 1:numGrid) {
    sigmaCand <- cands[ii]
    noiseSingVals <- singVals[singVals < sigmaCand * (1 + betaShrinkage)]
    card <- length(noiseSingVals)

    absVals <- numeric(card)

    for (jj in 1:card) {
      absVals[jj] <- abs(incMarPas((noiseSingVals[jj] / sigmaCand)^2, betaShrinkage, 0) - (jj - 0.5) / card)
    }

    objVals[ii] <- max(absVals) + 1 / (2 * card)
    cat(sprintf("Finished noise estimation candidate %d\n", ii))
  }

  minInd <- which.min(objVals)
  sigma <- cands[minInd]
  return(sigma)
}
# # Test script for ksOpt.R
#
# # from Matlab rng42
# library(R.matlab)
# data <- readMat('ksOpt_random_matrix.mat')
# singVals <- data$singVals
#
# # Define betaShrinkage parameter
# betaShrinkage <- 0.5  # Example
#
# # Run the ksOpt function
# sigma <- ksOpt(singVals, betaShrinkage)
#
# # Display the result
# cat("Test (sigma):\n")
# print(singVals)
#
# cat("Estimated noise level (sigma):\n")
# print(sigma)


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





#' Optimal Shrinkage of Singular Values
#'
#' The `optimal_shrinkage` function performs optimal shrinkage of singular values based on the specified loss function and estimated noise level. The function supports three types of loss functions: Frobenius ("fro"), operator norm ("op"), and nuclear norm ("nuc").
#'
#' @param singvals A numeric vector of singular values to be shrunk.
#' @param beta A numeric value representing the ratio of dimensions (min(n, d) / max(n, d)), where n and d are the dimensions of the matrix.
#' @param loss A string specifying the loss function to be used for shrinkage. Options are "fro" (Frobenius norm), "op" (operator norm), and "nuc" (nuclear norm).
#' @param percentile A numeric value representing the percentile used for noise level estimation if `sigma` is not provided.
#' @param sigma Optional. A numeric value representing the noise level. If not provided, it will be estimated using the Median Marcenko-Pastur distribution.
#'
#' @return A list containing:
#' \describe{
#'   \item{singvals}{The shrunk singular values as a numeric vector.}
#'   \item{noiselvl}{The estimated noise level used in the shrinkage process.}
#' }
#'
optimal_shrinkage <- function(singvals, beta, loss, percentile, sigma) {
  # similar to MATLAB assertions
  stopifnot(length(beta) == 1)
  stopifnot(beta <= 1)
  stopifnot(beta > 0)
  stopifnot(length(singvals) == length(singvals))
  stopifnot(loss %in% c("fro", "op", "nuc"))

  # Estimate sigma if needed
  #if nargin<5
  # warning('off','MATLAB:quadl:MinStepSize')''
  if (missing(sigma) ||is.null(sigma)) {
    MPmedian <- MedianMarcenkoPastur(beta)
    sigma <- stats::quantile(singvals, probs = percentile) / sqrt(MPmedian)
    cat(sprintf("estimated noise = %0.2f \n", sigma))
  }

  singvals <- optshrink_impl(singvals, beta, loss, sigma)
  noiselvl <- sigma

  return(list(singvals = singvals, noiselvl = noiselvl))
}





# function I = MarcenkoPasturIntegral(x, beta)
# if beta <= 0 || beta > 1
# error('beta beyond')
# end
# lobnd = (1 - sqrt(beta))^2;
# hibnd = (1 + sqrt(beta))^2;
# if (x < lobnd) || (x > hibnd)
# error('x beyond')
# end
# dens = @(t) sqrt((hibnd-t).*(t-lobnd))./(2*pi*beta.*t);
# I = integral(dens,lobnd,x);
# fprintf('x=%.3f,beta=%.3f,I=%.3f\n',x,beta,I);
# end







# incMarPas <- function(x0, beta, gamma) {
#   if (beta > 1) stop("beta beyond")
#
#   topSpec <- (1 + sqrt(beta))^2
#   botSpec <- (1 - sqrt(beta))^2
#   MarPas <- function(x) ifelse((topSpec - x) * (x - botSpec) > 0,
#                                sqrt((topSpec - x) * (x - botSpec)) / (beta * x) / (2 * pi),
#                                0)
#
#   if (gamma != 0) {
#     fun <- function(x) (x^gamma * MarPas(x))
#   } else {
#     fun <- MarPas
#   }
#
#   I <- integrate(fun, x0, topSpec)$value
#   return(I)
# }





####################################test######################################
# # from Matlab rng42
# library(R.matlab)
# data <- readMat('optimal_shrinkage_random_matrix.mat')
# X <- data$X
#
# svd_result <- svd(X)
# singvals <- svd_result$d
# beta <-  ncol(X)/nrow(X)
# percentile <- 0.9
# sigma <- 0.5
#
# # Apply op shrinkage
# result <- optimal_shrinkage(singvals, beta, loss = "op", percentile = percentile, sigma = sigma)
#
# cat("Original Singular Values:\n")
# print(singvals)
# cat("Shrunk Singular Values:\n")
# print(result$singvals)
# cat("Estimated Noise Level:\n")
# print(result$noiselvl)




#' Percentile of the Marcenko-Pastur Distribution
#'
#' This function calculates a specified percentile of the Marcenko-Pastur distribution, which is used in random matrix theory to model the distribution of singular values of large random matrices. It adjusts the percentile calculation based on the shape parameter `beta`.
#'
#' @param beta A numeric value representing the shape parameter of the Marcenko-Pastur distribution. It should be between 0 and 1.
#' @param perc A numeric value between 0 and 1, representing the desired percentile of the Marcenko-Pastur distribution.
#'
#' @return A numeric value representing the calculated percentile of the Marcenko-Pastur distribution.
#'
#'
PercentileMarcenkoPastur <- function(beta, perc) {
  nonzeroArea <- 1
  if (beta >= 1) {
    nonzeroArea <- 1 / beta
    perc <- perc * nonzeroArea
  }

  MarPas <- function(x) nonzeroArea - incMarPas(x, beta, 0)

  lobnd <- (1 - sqrt(beta))^2
  hibnd <- (1 + sqrt(beta))^2
  change <- TRUE

  while (change && (hibnd - lobnd > 0.001)) {
    change <- FALSE
    x <- seq(lobnd, hibnd, length.out = 5)
    y <- sapply(x, MarPas)

    if (any(y < perc)) {
      lobnd <- max(x[y < perc])
      change <- TRUE
    }

    if (any(y > perc)) {
      hibnd <- min(x[y > perc])
      change <- TRUE
    }
  }

  out <- (hibnd + lobnd) / 2
  return(out)
}



# incMarPas <- function(x0, beta, gamma) {
#   topSpec <- (1 + sqrt(beta))^2
#   botSpec <- (1 - sqrt(beta))^2
#
#   MarPas <- function(x) {
#     ifelse((topSpec - x) * (x - botSpec) > 0,
#            sqrt(pmax((topSpec - x) * (x - botSpec), 0)) / (beta * x) / (2 * pi),
#            0)
#   }
#
#   if (gamma != 0) {
#     fun <- function(x) x^gamma * MarPas(x)
#   } else {
#     fun <- MarPas
#   }
#
#   I <- integrate(fun, x0, topSpec)$value
#   return(I)
# }


# # Test script for PercentileMarcenkoPastur.R
#
# beta <- 0.5
# perc <- 0.9
#
#
# result <- PercentileMarcenkoPastur(beta, perc)
#
# # Display the result
# cat("Test for PercentileMarcenkoPastur in R\n")
# cat("Beta:", beta, "\n")
# cat("Percentile:", perc, "\n")
# cat("Result:", result, "\n")




#' Simulate Random Direction Angles in Vector Space
#'
#' This function simulates the angles between a random direction and a fixed rank `r` subspace in \eqn{R^n}.
#' Specifically, it calculates the angles between a random vector and the subspace spanned by the first `r`
#' dimensions in an \eqn{n}-dimensional space.
#'
#' @param n An integer representing the dimension of the vector space.
#' @param r An integer representing the dimension of the subspace.
#' @param nsim An integer representing the number of simulation samples.
#'
#' @return A numeric vector of length `nsim`, containing the simulated random direction angles (in degrees).
#'
randDirAngleMJ <- function(n, r, nsim) {
  # randDirAngleMJ   calculate random direction angle
  #   Simulate the angles between a random direction and a fixed rank r
  #   subspace in R^n (in this case the subspace of the first r dimensions).
  #
  # Inputs:
  #   n - dimension of vector space
  #   r - dimension of subspace
  #   nsim - number of simulation samples
  #
  # Outputs:
  #   angles - nsim x 1 simulated random direction angles
  angles <- numeric(nsim)

  for (i in 1:nsim) {
    vec <- stats::rnorm(n)
    angles[i] <- acos(sum(vec[1:r]^2)^0.5 / sum(vec^2)^0.5) * 180 / pi
  }
  return(angles)
}

