#' Optimal Shrinkage Estimation using Kolmogorov-Smirnov Criterion
#'
#' This function estimates the optimal shrinkage parameter for singular values using the Kolmogorov-Smirnov (KS) criterion, which helps identify noise levels in high-dimensional data.
#'
#' @param singVals A numeric vector of singular values from a data matrix.
#' @param betaShrinkage A numeric value representing the aspect ratio of the data matrix (ratio of columns to rows or vice versa).
#'
#' @return A numeric value representing the estimated optimal noise level (sigma) based on the KS criterion.
#' @export
#'
ksOpt <- function(singVals, betaShrinkage) {
  sigmaMin <- median(singVals) / (1 + sqrt(betaShrinkage))
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


#' Incomplete Marčenko-Pastur Distribution Function
#'
#' Computes the incomplete Marčenko-Pastur distribution function, which is used in estimating noise levels.
#'
#' @param x0 A numeric value representing the lower limit of integration.
#' @param beta A numeric value indicating the ratio of columns to rows in the data matrix.
#' @param gamma A numeric value specifying the power to which the function should be raised during integration.
#'
#' @return A numeric value of the integrated Marčenko-Pastur function.
#' @export
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

  I <- integrate(fun, x0, topSpec)$value
  return(I)
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

