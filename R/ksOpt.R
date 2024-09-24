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

