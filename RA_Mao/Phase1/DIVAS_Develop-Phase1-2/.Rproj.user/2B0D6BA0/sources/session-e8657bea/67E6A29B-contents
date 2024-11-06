#' Signal Matrix Extraction for DJIVE
#'
#' Extracts the signal matrix for each data block, estimates signal ranks, and adjusts perturbation angles for each data matrix.
#'
#' @param datablock A list of data matrices, each matrix corresponding to a data block.
#' @param dataname A character vector of names for each data matrix.
#' @param nsim An integer specifying the number of bootstrap samples.
#' @param iplot A logical (0 or 1) to indicate whether plots should be generated for visualizing singular value shrinkage.
#' @param colCent A logical (0 or 1) indicating whether columns should be centered.
#' @param rowCent A logical (0 or 1) indicating whether rows should be centered.
#' @param cull A numeric value for the culling parameter to adjust signal rank.
#' @param noisepercentile A numeric vector specifying the percentiles used for noise estimation for each data block.
#' @param noiselvls A list specifying noise levels for each data block; if NULL, noise levels are estimated internally.
#'
#' @return A list containing:
#'   \describe{
#'     \item{VBars}{List of adjusted signal row spaces for each data block.}
#'     \item{UBars}{List of adjusted signal column spaces for each data block.}
#'     \item{phiBars}{Vector of adjusted perturbation angles for each data matrix.}
#'     \item{psiBars}{Vector of loadings perturbation angles for each data matrix.}
#'     \item{rBars}{Vector of adjusted signal ranks for each data block.}
#'     \item{EHats}{List of estimated noise matrices for each data block.}
#'     \item{singVals}{List of singular values before shrinkage for each data block.}
#'     \item{singValsHat}{List of singular values after shrinkage for each data block.}
#'     \item{rSteps}{List of signal rank adjustment steps for each data block.}
#'     \item{VVHatCacheBars}{List of cached VVHat matrices for bootstrap samples.}
#'     \item{UUHatCacheBars}{List of cached UUHat matrices for bootstrap samples.}
#'   }
#' @import RSpectra
#' @export
DJIVESignalExtractJP <- function(datablock, dataname, nsim, iplot, colCent, rowCent, cull, noisepercentile, noiselvls = NULL) {

  nb <- length(datablock)
  # library(RSpectra)

  # Initialize the output lists
  VBars <- vector("list", nb)
  UBars <- vector("list", nb)
  EHats <- vector("list", nb)
  phiBars <- rep(90, nb)
  psiBars <- rep(90, nb)
  rBars <- numeric(nb)
  singVals <- vector("list", nb)
  singValsHat <- vector("list", nb)
  rSteps <- vector("list", nb)
  VVHatCacheBars <- vector("list", nb)
  UUHatCacheBars <- vector("list", nb)

  # Loop through each block
  for (ib in 1:nb) {
    cat(sprintf('Signal estimation for %s\n', dataname[ib]))
    datablockc <- datablock[[ib]]
    d <- nrow(datablockc)
    n <- ncol(datablockc)
    percentile <- noisepercentile[ib]
    print('datablockc size')
    print(dim(datablockc))
    # Check if noiselvls is provided or not
    if (is.null(noiselvls)) {
      result <- MatSignalExtractJP(datablockc, dataname[ib], nsim, colCent, rowCent, cull, percentile)
    } else {
      result <- MatSignalExtractJP(datablockc, dataname[ib], nsim, colCent, rowCent, cull, noiselvls[[ib]])
    }

    VBars[[ib]] <- result$VBar
    UBars[[ib]] <- result$UBar
    phiBars[ib] <- result$phiBar
    psiBars[ib] <- result$psiBar
    rBars[ib] <- result$rBar
    EHats[[ib]] <- result$EHat
    singVals[[ib]] <- result$singVals
    singValsHat[[ib]] <- result$singValsHat
    rSteps[[ib]] <- result$rSteps
    VVHatCacheBars[[ib]] <- result$VVHatCacheBar
    UUHatCacheBars[[ib]] <- result$UUHatCacheBar
  }

  # Plotting (if iplot is set to 1)
  if (iplot == 1) {
    for (ib in 1:nb) {
      singValsI <- singVals[[ib]]
      singValsHatI <- singValsHat[[ib]]
      rStepsI <- rSteps[[ib]]
      rHat <- sum(singValsHatI > 0)
      rBar <- rBars[ib]
      matName <- dataname[ib]

      topPlot <- max(singValsI) + 5
      topRanges <- topPlot * (1:length(rStepsI)) / length(rStepsI)
      botRanges <- topRanges - (topPlot / length(rStepsI))

      plot(1:min(d, n), singValsI, type = "b", col = "blue", pch = 16, ylim = c(0, topPlot), xlab = "Index", ylab = "Singular Value",
           main = paste0(matName, " Singular Value Shrinkage & Culling"))
      points(1:min(d, n), singValsHatI, type = "b", col = "red", pch = 4)
      abline(v = rHat, col = "red", lty = 2)
      abline(v = rBar, col = "black", lty = 3)

      for (i in 1:length(rStepsI)) {
        redProp <- (length(rStepsI) - i) / (length(rStepsI) - 1)
        segments(rStepsI[i], botRanges[i], rStepsI[i], topRanges[i], col = rgb(redProp, 0, 0))
      }
    }
  }

  # Return the results as a list
  return(list(VBars = VBars, UBars = UBars, phiBars = phiBars, psiBars = psiBars, EHats = EHats, rBars = rBars,
              singVals = singVals, singValsHat = singValsHat, rSteps = rSteps, VVHatCacheBars = VVHatCacheBars, UUHatCacheBars = UUHatCacheBars))
}

# ####################
# library(R.matlab)
# # datablock <- data$datablock
# data <- readMat('/Users/byronsun/Desktop/RA_Mao/R code DIVAS/Data/toyDataThreeWay.mat')
#
# # datablocks from the list and convert to matrix
# datablock <- lapply(data$datablock, function(x) x[[1]])
# datablock <- matrix(list(datablock[[1]], datablock[[2]], datablock[[3]]), nrow = 1, ncol = 3)
#
#
# dataname <- c('datablock1', 'datablock2', 'datablock3')
# nsim <- 400
# iplot <- 0
# colCent <- 0
# rowCent <- 0
# cull <- 0.5
# noisepercentile <- c(0.9, 0.85, 0.8) # not real
#
# result <- DJIVESignalExtractJP(
#   datablock = datablock,
#   dataname = dataname,
#   nsim = nsim,
#   iplot = iplot,
#   colCent = colCent,
#   rowCent = rowCent,
#   cull = cull,
#   noisepercentile = noisepercentile
# )
#
#
# cat("Adjusted signal ranks (rBars):\n")
# print(result$rBars)
#
# cat("Perturbation angles (phiBars):\n")
# print(result$phiBars)
#
# cat("Loadings perturbation angles (psiBars):\n")
# print(result$psiBars)
#
# # for (i in 1:length(result$singVals)) {
# #   cat(sprintf("Singular values before shrinkage for block %d:\n", i))
# #   print(result$singVals[[i]])
# #
# #   cat(sprintf("Singular values after shrinkage for block %d:\n", i))
# #   print(result$singValsHat[[i]])
# # }
#
# # for (i in 1:length(result$rSteps)) {
# #   cat(sprintf("Signal rank adjustment steps for block %d:\n", i))
# #   print(result$rSteps[[i]])
# # }
# #
# # # Dim check - Sizes of VBars
# # cat("Size of VBars for each block:\n")
# # for (i in 1:length(result$VBars)) {
# #   cat(sprintf("Block %d - Size of VBars: %d x %d\n", i, nrow(result$VBars[[i]]), ncol(result$VBars[[i]])))
# # }
# #
# # # Dim check - Sizes of UBars
# # cat("Size of UBars for each block:\n")
# # for (i in 1:length(result$UBars)) {
# #   cat(sprintf("Block %d - Size of UBars: %d x %d\n", i, nrow(result$UBars[[i]]), ncol(result$UBars[[i]])))
# # }
# #
# # # Dim check - Sizes of EHats (Noise matrices)
# # cat("Size of EHats (Noise matrices) for each block:\n")
# # for (i in 1:length(result$EHats)) {
# #   cat(sprintf("Block %d - Size of EHats: %d x %d\n", i, nrow(result$EHats[[i]]), ncol(result$EHats[[i]])))
# # }
#



