#' Data integration via analysis of subspaces
#'
#' Main function for DIVAS analysis. Given a list of data blocks with matched columns (samples), will return identified joint
#' structure with diagnostic plots.
#'
#' @param datablock A list of matrices with the same number of columns (samples).
#' @param nsim Number of bootstrap resamples for inferring angle bounds.
#' @param iprint Whether to print diagnostic figures.
#' @param colCent Whether to column centre the input data blocks.
#' @param rowCent Whether to row centre the input data blocks.
#' @param figdir If not NULL, then diagnostic plots will be saved to this directory.
#'
#' @return A list containing DIVAS integration results. Most important ones include
#'   \describe{
#'     \item{matBlocks}{List of scores representing shared and partially shared joint structures.}
#'     \item{matLoadings}{List of loadings linking features in each data block with scores.}
#'     \item{keyIdxMap}{Mapping between indices of the previous lists and data blocks.}
#'   }
#'   See Details for more explanations.
#'
#' @details
#' DIVASmain returns a list containing all important information returned from the DIVAS algorithm.
#' For users, the most important ones are scores (matBlocks), loadings (matLoadings) and an index
#' book (keyIdxMap) explaining what joint structures each score or loading matrix correpsond to.
#'
#' matBlocks is a list containing scores. Each element of matBlocks is indexed by a number.
#' For example, suppose one of the indices is "7", then keyIdxMap[["7"]] contains indices of data blocks
#' corresponding to the index 7. That is, matBlocks[["7"]] contains the scores for all samples
#' representing the joint structures of data blocks in keyIdxMap[["7"]].
#'
#' @references
#' Prothero, J., Jiang, M., Hannig, J., Tran-Dinh, Q., Ackerman, A. and Marron, J. S. (2024).
#' Data integration via analysis of subspaces (DIVAS). Test.
#'
#'
#' @export
DIVASmain <- function(
    datablock, nsim = 400, iprint = TRUE, colCent = FALSE, rowCent = FALSE,
    figdir = NULL
  ){

  # Initialize parameters
  nb <- length(datablock)
  dataname <- names(datablock)
  if(is.null(dataname)){
    warning("Input datablock is unnamed, generic names for data blocks generated.")
    dataname <- paste0("Datablock", 1:nb)
  }

  # Some tuning parameters for algorithms
  theta0 <- 45
  optArgin <- list(0.5, 1000, 1.05, 50, 1e-3, 1e-3)
  filterPerc <- 1 - (2 / (1 + sqrt(5))) # "Golden Ratio"
  noisepercentile <- rep(0.5, nb)


  rowSpaces <- vector("list", nb)
  # datablockc <- vector("list", nb)
  for (ib in seq_len(nb)) {
    rowSpaces[[ib]] <- 0
    datablock[[ib]] <- MatCenterJP(datablock[[ib]], colCent, rowCent)
  }

  # Step 1: Estimate signal space and perturbation angle
  Phase1 <- DJIVESignalExtractJP(
    datablock = datablock, nsim = nsim,
    iplot = FALSE, colCent = colCent, rowCent = rowCent, cull = filterPerc, noisepercentile = noisepercentile
  )
  # VBars <- Phase1[[1]]
  # UBars <- Phase1[[2]]
  # phiBars <- Phase1[[3]]
  # psiBars <- Phase1[[4]]
  # rBars <- Phase1[[6]]
  # VVHatCacheBars <- Phase1[[10]]
  # UUHatCacheBars <- Phase1[[11]]


  # Step 2: Estimate joint and partially joint structure
  Phase2 <- DJIVEJointStrucEstimateJP(
    VBars = Phase1$VBars, UBars = Phase1$UBars, phiBars =  Phase1$phiBars, psiBars =  Phase1$psiBars,
    rBars = Phase1$rBars, dataname = dataname, iprint = iprint, figdir = figdir
  )

  # outMap <- Phase2[[1]]
  # keyIdxMap <- Phase2[[2]]
  # jointBlockOrder <- Phase2[[4]]

  # Step 3: Reconstruct DJIVE decomposition
  outstruct <- DJIVEReconstructMJ(
    datablock = datablock, dataname =  dataname, outMap =  Phase2$outMap,
    keyIdxMap =  Phase2$keyIdxMap, jointBlockOrder =  Phase2$jointBlockOrder, doubleCenter =  0
  )

  outstruct$rBars <- Phase1$rBars
  outstruct$phiBars <- Phase1$phiBars
  outstruct$psiBars <- Phase1$psiBars
  outstruct$VBars <- Phase1$VBars
  outstruct$UBars <- Phase1$UBars
  outstruct$VVHatCacheBars <- Phase1$VVHatCacheBars
  outstruct$UUHatCacheBars <- Phase1$UUHatCacheBars
  outstruct$jointBasisMapRaw <- Phase2$outMap

  return(outstruct)
}

