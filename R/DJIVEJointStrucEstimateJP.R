#' Estimate full and partially shared joint structures
#' Establish a DC programming problem to estimate each partially joint structure using Penalty CCP algorithm.
#'
#' @param VBars List of adjusted signal row spaces for each data block.
#' @param UBars List of adjusted signal column spaces for each data block.
#' @param phiBars Vector of adjusted perturbation angles for each data matrix.
#' @param psiBars Vector of loadings perturbation angles for each data matrix.
#' @param rBars Vector of adjusted signal ranks for each data block.
#' @param dataname Names of data blocks.
#' @param theta0 Initial value for angle.
#' @param optArgin Aditional tuning parameters for optimisation.
#' @param iprint Print the figures or not.
#' @param figdir If not `NULL`, will be parsed as directory for storing the figures.
#'
#' @return A list containing:
#'   \describe{
#'     \item{outMap}{Mapping between joint block index set and estimated partially shared structure.}
#'     \item{keyIdxMap}{Mapping between joint block index and data blocks.}
#'     \item{anglesMap}{Mapping between joint block index and angle estimates.}
#'     \item{jointBlockOrder}{Record of the order of joint blocks.}
#'   }
#'
#' @export
DJIVEJointStrucEstimateJP <- function(
    VBars, UBars, phiBars, psiBars, rBars,
    dataname = NULL, theta0 = 45, optArgin = list(), iprint = F, figdir = NULL
  ) {

  nb <- length(VBars)
  allIdx <- 1:nb
  curRanks <- rep(0, nb)

  outMap <- list()
  keyIdxMap <- list()
  anglesMap <- list()
  jointBlockOrder <- list()

  flag <- FALSE

  if(is.null(dataname)){
    message("Names of data blocks not provided. Will use generic names.\n")
    dataname <- paste0("Datablock", 1:nb)
  }

  for (len in nb:1) {

    # if (len <= nb) {
    #   lenIdces <- combn(allIdx, len)
    #   nlen <- ncol(lenIdces)
    # } else {
    #   next
    # # }
    # tryCatch({
    #   lenIdces <- combn(allIdx, len)
    #   nlen <- ncol(lenIdces)
    # }, error = function(e) {
    #   cat("Error in combn: n =", nb, ", m =", len, "\n")
    #   stop(e)
    # })

   # if (exists("lenIdces")) {
   #    nlen <- ncol(lenIdces)
   #    cat("Combination lenIdces: \n")
   #    print(lenIdces)
   #    cat("Combination lenIdces: \n")
   #    print(lenIdces)
   #  }

    lenIdces <- utils::combn(allIdx, len)
    nlen <- ncol(lenIdces)

    for (i in 1:nlen) {
      blockIdx <- lenIdces[, i]
      blockIn <- allIdx %in% blockIdx

      # Check if current ranks + blockIn exceed rBars
      if (any(curRanks + as.integer(blockIn) > rBars)) {
        next
      }


      result_Joint <- BlockJointStrucEstimateJP(
        blockIn = blockIn, dataname = dataname, VBars = VBars, phiBars =phiBars,
        rBars = rBars, curRanks = curRanks, outMap = outMap, theta0 = theta0,
        optArgin = optArgin, iprint = iprint, figdir = figdir
      )
      Vi <- result_Joint$Vi
      curRanks <- result_Joint$curRanks
      angles <- result_Joint$angles

      if (ncol(Vi) > 0) {
        t <- Idx2numMJ(blockIn)
        outMap[[as.character(t)]] <- Vi
        keyIdxMap[[as.character(t)]] <- blockIdx
        anglesMap[[as.character(t)]] <- angles
        jointBlockOrder <- c(jointBlockOrder, as.character(t))
      }

      # Stop if no more room for joint blocks
      if (all(curRanks == rBars)) {
        cat("There is no room for the next joint block. Stop searching.\n")
        flag <- TRUE
        break
      }
    }

    if (flag) {
      break
    }
  }

  return(list(outMap = outMap, keyIdxMap = keyIdxMap, anglesMap = anglesMap, jointBlockOrder = jointBlockOrder))
}



# library(R.matlab)
#
# toydata <- readMat("/Users/byronsun/Desktop/RA_Mao/DIVAS2021-main/DJIVECode/toyDataThreeWay.mat")
#
# # Extract data blocks from the loaded structure
# #datablock <- list(toydata$block1, toydata$block2, toydata$block3)
#
# datablock <- lapply(data$datablock, function(x) x[[1]])
# datablock <- matrix(list(datablock[[1]], datablock[[2]], datablock[[3]]), nrow = 1, ncol = 3)
#
# #
# dataname <- c("datablock1", "datablock2", "datablock3")
# theta0 <- 45
# optArgin <- list(0.5, 1000, 1.05, 200, 1e-3, 1e-3)
# iprint <- 1
# figdir <- ""
#
# nsim <- 400
# iplot <- 0
# colCent <- 0
# rowCent <- 0
# cull <- 0.5
# noisepercentile <- rep(0.5, 3)
#
# Result_P1 <- DJIVESignalExtractJP(
#   datablock = datablock,
#   dataname = dataname,
#   nsim = nsim,
#   iplot = iplot,
#   colCent = colCent,
#   rowCent = rowCent,
#   cull = cull,
#   noisepercentile = noisepercentile
# )
# #
# # # Ensure data blocks are centered if necessary (similar to MATLAB)
# # # In this example, we'll assume the data is already centered
# #
# # # Run DJIVESignalExtractJP to estimate signal space and angles
# # #result <- DJIVESignalExtractJP(datablock, dataname, 400, 0, 0, 0, 0.618, rep(0.5, length(datablock)))
# #
# # # Extract the components from the result
# VBars <- Result_P1$VBars
# UBars <- Result_P1$UBars
# phiBars <- Result_P1$phiBars
# psiBars <- Result_P1$psiBars
# rBars <- Result_P1$rBars
#
# # Test the DJIVEJointStrucEstimateJP function
# Result_P2 <- DJIVEJointStrucEstimateJP(VBars, UBars, phiBars, psiBars, rBars, dataname, theta0, optArgin, iprint, figdir)
#
# outMap <- Result_P2$outMap
# keyIdxMap <- Result_P2$keyIdxMap
# anglesMap <- Result_P2$anglesMap
# jointBlockOrder <- Result_P2$jointBlockOrder
###11111111
# cat("outMap:\n")
# print(outMap)
#
# cat("keyIdxMap:\n")
# print(keyIdxMap)
#
# cat("anglesMap:\n")
# print(anglesMap)
#
# cat("jointBlockOrder:\n")
# print(jointBlockOrder)


# # Mock data for testing
# VBars <- list(
#   matrix(c(1, 0, 0, 0, 1, 0, 0, 0, 1), nrow = 3, byrow = TRUE),
#   matrix(c(0.5, 0.5, 0, 0.5, 0.5, 1, 0, 1, 0), nrow = 3, byrow = TRUE),
#   matrix(c(0.6, 0.8, 0, 0.8, -0.6, 0, 0, 0, 1), nrow = 3, byrow = TRUE)
# )
# UBars <- VBars
# phiBars <- c(30, 45, 60)
# psiBars <- c(30, 45, 60)
# rBars <- c(2, 2, 2)
# dataname <- list("Data1", "Data2", "Data3")
# theta0 <- 45
# optArgin <- list(tau0 = 0.5, tau_max = 1000, mu = 1.05, t_max = 200, tol = 1e-3, delta = 1e-3)
#
#
# result <- DJIVEJointStrucEstimateJP(VBars, UBars, phiBars, psiBars, rBars, dataname, theta0, optArgin, 1, "")
#
# cat("outMap:\n")
# print(result$outMap)
#
# cat("keyIdxMap:\n")
# print(result$keyIdxMap)
#
# cat("anglesMap:\n")
# print(result$anglesMap)
#
# cat("jointBlockOrder:\n")
# print(result$jointBlockOrder)
#
#
# #################
# VBars <- list(
#   matrix(c(1, 0, 0, 0, 1, 0, 0, 0, 1), nrow = 3, byrow = TRUE),
#   matrix(c(0.5, 0.5, 0, 0.5, 0.5, 1, 0, 1, 0), nrow = 3, byrow = TRUE),
#   matrix(c(0.6, 0.8, 0, 0.8, -0.6, 0, 0, 0, 1), nrow = 3, byrow = TRUE)
# )
# nb <- length(VBars)
# allIdx <- 1:nb
#
# for (len in nb:1) {
#   print('allIdx')
#   print(allIdx)
#   print('len')
#   print(len)
#   lenIdces <- combn(allIdx, len)
#   nlen <- ncol(lenIdces)
# }
