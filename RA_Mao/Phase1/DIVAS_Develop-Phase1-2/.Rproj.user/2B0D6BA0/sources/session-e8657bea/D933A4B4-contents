#' Estimate Joint and Partially Joint Structures using DJIVE Method
#'
#' The function `DJIVEJointStrucEstimateJP` establishes a DC programming problem to estimate joint
#' and partially joint structures in a set of adjusted signal row spaces using the Penalty CCP algorithm.
#'
#' @param VBars A list of adjusted signal row spaces.
#' @param UBars A list of orthogonal signal column spaces (optional, can be NULL).
#' @param phiBars A numeric vector of perturbation angles for each data matrix.
#' @param psiBars A numeric vector of additional perturbation angles for column spaces.
#' @param rBars A numeric vector of adjusted signal ranks for each data matrix.
#' @param dataname A character vector of data matrix names.
#' @param theta0 A numeric value representing the base angle for perturbation. Default is 45 degrees.
#' @param optArgin A list of optional arguments for optimization.
#' @param iprint An integer for verbosity level. Default is 0.
#' @param figdir A character string indicating where to save output figures.
#'
#' @return A list containing:
#'   \item{outMap}{A mapping between joint block index set and estimated partially shared structures.}
#'   \item{keyIdxMap}{A mapping between joint block indices and data blocks.}
#'   \item{anglesMap}{A mapping between joint block indices and estimated angles.}
#'   \item{jointBlockOrder}{A record of the order of the joint blocks.}
#' @importFrom utils combn
#' @importFrom Matrix diag
#' @export
DJIVEJointStrucEstimateJP <- function(VBars, UBars, phiBars, psiBars, rBars, dataname, theta0 = 45, optArgin = list(), iprint = 0, figdir = "") {
  nb <- length(VBars)
  allIdx <- 1:nb
  curRanks <- rep(0, nb)

  # Initialize output mappings
  outMap <- list()
  keyIdxMap <- list()
  anglesMap <- list()
  jointBlockOrder <- list()

  flag <- FALSE

  # Iterate over combinations of blocks, starting from the full set and reducing
  for (len in nb:1) {
    # Generate all combinations of block indices for the current length
    lenIdces <- combn(allIdx, len)
    nlen <- ncol(lenIdces)

    for (i in 1:nlen) {
      blockIdx <- lenIdces[, i]
      blockIn <- allIdx %in% blockIdx

      # Check if the new combination would exceed adjusted signal ranks
      if (any(curRanks + as.integer(blockIn) > rBars)) {
        next
      }

      # Estimate joint structure for the given combination
      result_Joint <- BlockJointStrucEstimateJP(blockIn, dataname, VBars, phiBars, rBars, curRanks, outMap, theta0, optArgin, iprint, figdir)
      Vi <- result_Joint$Vi
      curRanks <- result_Joint$curRanks
      angles <- result_Joint$angles

      # If Vi has valid content, add the results to the output mappings
      if (ncol(Vi) > 0) {
        t <- Idx2numMJ(blockIn)
        outMap[[as.character(t)]] <- Vi
        keyIdxMap[[as.character(t)]] <- blockIdx
        anglesMap[[as.character(t)]] <- angles
        jointBlockOrder <- c(jointBlockOrder, as.character(t))
      }

      # Check if we can stop further joint block searches
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
