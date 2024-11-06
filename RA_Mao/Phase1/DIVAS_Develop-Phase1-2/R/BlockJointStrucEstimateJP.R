#' Estimate Joint Structure Shared by Blocks
#'
#' Estimates the joint structure shared among multiple data matrices (blocks).
#' This function finds joint structures by optimizing an objective function and
#' adjusting the search direction iteratively.
#'
#' @param blockIn A logical vector indicating which blocks are included.
#' @param dataname A character vector of data matrix names.
#' @param VBars A list of matrices, each representing the adjusted signal row spaces.
#' @param phiBars A numeric vector of perturbation angles for each data matrix.
#' @param rBars A numeric vector of adjusted signal ranks for each data matrix.
#' @param curRanks A numeric vector indicating current ranks.
#' @param outMap A list mapping between joint block index set and estimated shared structure.
#' @param theta0 A numeric value representing the base angle for perturbation. Default is 45 degrees.
#' @param optArgin A list of optional arguments for optimization.
#' @param iprint An integer for verbosity level. Default is 0.
#' @param figdir A character string indicating where to save output figures.
#'
#' @return A list containing:
#'   \item{Vi}{Matrix of joint structure vectors.}
#'   \item{curRanks}{Updated ranks after estimation.}
#'   \item{angles}{Matrix of angles estimated for each search direction.}
#' @importFrom Matrix diag
#' @importFrom RSpectra svds
#' @export
BlockJointStrucEstimateJP <- function(blockIn, dataname, VBars, phiBars, rBars, curRanks, outMap, theta0 = 45, optArgin = list(), iprint = 0, figdir = "") {
  nb <- length(blockIn)
  allIdx <- 1:nb
  blockIdx <- allIdx[blockIn]
  blockName <- dataname[blockIn]

  cat(paste("Find joint structure shared only among", paste(blockName, collapse = ", "), ".\n"))

  n <- nrow(VBars[[1]])
  blockLen <- sum(blockIn)

  Mo1 <- NULL
  Mo2 <- NULL
  Qc1 <- vector("list", nb)
  Qc2 <- vector("list", nb)

  for (ib in 1:nb) {
    if (blockIn[ib]) {
      Mo2 <- cbind(Mo2, VBars[[ib]])
      Qc1[[ib]] <- diag(n)
      Qc2[[ib]] <- VBars[[ib]] %*% t(VBars[[ib]]) / cos(phiBars[ib] * pi / 180)^2
    } else {
      Qc1[[ib]] <- VBars[[ib]] %*% t(VBars[[ib]]) / cos(phiBars[ib] * pi / 180)^2
      Qc2[[ib]] <- diag(n)
    }
  }

  Qo1 <- if (is.null(Mo1)) diag(n) * 1e-6 else Mo1 %*% t(Mo1)
  Qo2 <- if (is.null(Mo2)) diag(n) * 1e-6 else Mo2 %*% t(Mo2)

  Vorth <- matrix(0, n, 1)

  for (len in nb:(blockLen + 1)) {
    if (len > length(allIdx)) next
    lenIdces <- combn(allIdx, len)
    for (i in 1:ncol(lenIdces)) {
      bkIdx <- lenIdces[, i]
      bkIn <- allIdx %in% bkIdx
      t <- Idx2numMJ(bkIn)

      if (!is.element(as.character(t), names(outMap))) next

      if (all(blockIdx %in% bkIdx)) {
        Vorth <- cbind(Vorth, outMap[[as.character(t)]])
      } else {
        Vnorth <- cbind(Vnorth, outMap[[as.character(t)]])
      }
    }
  }

  if (!is.null(Vnorth) && ncol(Vnorth) > 0) {
    Qc1[[length(Qc1) + 1]] <- Vnorth %*% t(Vnorth) / cos(theta0)^2
    Qc2[[length(Qc2) + 1]] <- diag(n)
  }

  V0 <- svds(Qo2, k = max(rBars[blockIn]))$v
  Vi <- NULL
  angles <- matrix(0, nrow = nb, ncol = ncol(V0))

  j <- 0
  searchNext <- TRUE

  while (searchNext) {
    j <- j + 1
    cat(sprintf("Search Direction %d:\n", j))

    result <- penaltyCCPJPEarlyStop(V0[, j], Qo1, Qo2, Qc1, Qc2, Vorth, optArgin)
    opt_v <- result$opt_v
    cache_v <- result$cache_v
    converge <- result$converge

    if (!converge) {
      cat(sprintf("Direction %d does not converge. Stop searching current joint block.\n", j))
      break
    }

    Vi <- cbind(Vi, opt_v)
    curRanks <- curRanks + blockIn

    if (any(curRanks + blockIn > rBars)) {
      cat("There is no room for searching next direction. Stop searching current joint block.\n")
      searchNext <- FALSE
    } else {
      cat("There is room for searching next direction. Continue...\n")
    }
  }

  angles <- angles[, 1:(ncol(Vi) + 1 * !any(curRanks + blockIn > rBars))]

  return(list(Vi = Vi, curRanks = curRanks, angles = angles))
}
