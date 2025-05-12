#' Signal Matrix Extraction for DIVAS
#'
#' Extracts the signal matrix for each data block, estimates signal ranks, and adjusts perturbation angles for each data matrix.
#'
#' @param datablock A list of feature by sample (eg gene by cell) data matrices, each matrix corresponding to a data block. Matrices have to have same number of columns (mathced samples).
#' @param nsim An integer specifying the number of bootstrap samples.
#' @param iplot A logical to indicate whether plots should be generated for visualizing singular value shrinkage.
#' @param colCent A logical indicating whether columns should be centered.
#' @param rowCent A logical indicating whether rows should be centered.
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
DJIVESignalExtractJP <- function(
    datablock, nsim = 400,
    iplot = FALSE, colCent = F, rowCent = F, cull = 0.382,
    noisepercentile = rep(0.5, length(datablock)), noiselvls = NULL
){

  # Check input dimensions
  if(!methods::is(datablock, "list")) stop("Input datablock has to be a list with length >= 2.")
  if(length(datablock) < 2) stop("Input datablock has to be a list with length >= 2.")
  if(max(sapply(datablock, ncol)) != min(sapply(datablock, ncol))) stop("All data blocks have to have the same number of columns (samples).")

  # Check data block names
  nb <- length(datablock)
  dataname <- names(datablock)
  if(is.null(dataname)){
    warning("Input datablock is unnamed, generic names for data blocks generated.")
    dataname <- paste0("Datablock", 1:nb)
  }

  print(length(noisepercentile))
  print(length(datablock))

  # Check noisepercentile length
  if(length(noisepercentile) != length(datablock)) stop("Input noisepercentile has to have the same length as datablock (ie number of data blocks).")

  # Initialize the output lists
  VBars <- vector("list", nb) # adjusted signal row spaces
  UBars <- vector("list", nb) # adjusted signal column spaces
  EHats <- vector("list", nb) # estimated noise matrices
  phiBars <- rep(90, nb) # adjusted perturbation angles
  psiBars <- rep(90, nb) # loadings perturbation angles
  rBars <- numeric(nb) # adjusted signal ranks
  singVals <- vector("list", nb) # singular values before shrinkage
  singValsHat <- vector("list", nb) # singular values after shrinkage
  rSteps <- vector("list", nb) # signal rank adjustment steps
  VVHatCacheBars <- vector("list", nb) # cached VVHat matrices for bootstrap samples
  UUHatCacheBars <- vector("list", nb) # cached UUHat matrices for bootstrap samples

  # Loop through each block
  for (ib in 1:nb) {

    cat(sprintf('Signal estimation for %s\n', dataname[ib]))

    datablockc <- datablock[[ib]]
    d <- nrow(datablockc)
    n <- ncol(datablockc)
    percentile <- noisepercentile[ib]
    cat('Datablock dimensions:', d, "features;", n, "samples \n")

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

  # Plotting (if iplot is TRUE)
  if (iplot) {
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
      graphics::points(1:min(d, n), singValsHatI, type = "b", col = "red", pch = 4)
      graphics::abline(v = rHat, col = "red", lty = 2)
      graphics::abline(v = rBar, col = "black", lty = 3)

      for (i in 1:length(rStepsI)) {
        redProp <- (length(rStepsI) - i) / (length(rStepsI) - 1)
        graphics::segments(rStepsI[i], botRanges[i], rStepsI[i], topRanges[i], col = grDevices::rgb(redProp, 0, 0))
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



