#' MatReconstructMJ - Reconstruct joint block matrices and their loadings from data
#'
#' @param X d x n data matrix
#' @param matJointV n x sum(r_t) joint structure basis matrix
#' @param matJointOrder List that keeps the order of joint blocks in matJointV
#' @param matJointRanks Vector containing the rank of each joint block in matJointV
#'
#' @return A list containing `matBlockMap` (joint block matrix map) and `matLoadingMap` (joint block loading map)
MatReconstructMJ <- function(X, matJointV, matJointOrder, matJointRanks) {
  # Solve linear equation to get the loadings
  #matLoading <- t(solve(t(matJointV), t(X)))
  #matLoading <- t(solve(t(matJointV) %*% matJointV) %*% t(matJointV) %*% t(X))
  #matLoading <- t(ginv(matJointV) %*% t(X))
  matLoading <- t(qr.solve(matJointV, t(X)))

  #print(matLoading)
  matBlockMap <- list()
  matLoadingMap <- list()
  cum <- 0


  for (j in seq_along(matJointOrder)) {
    t <- matJointOrder[[j]]
    r <- matJointRanks[j]
    Vhat <- matJointV[, (cum + 1):(cum + r)]
    #Bhat <- matLoading[, (cum + 1):(cum + r)]
    Bhat <- matLoading[, (cum + 1):(cum + r)]
    matBlockMap[[as.character(t)]] <- Bhat %*% t(Vhat)
    matLoadingMap[[as.character(t)]] <- Bhat
    cum <- cum + r
  }

  return(list(matBlockMap = matBlockMap, matLoadingMap = matLoadingMap))
}







#' DJIVEReconstructMJ - Reconstruct joint blocks from data blocks
#'
#' This function reconstructs joint blocks from the provided data matrices
#' using the estimated partially shared structures.
#'
#' @param datablock List of d_k x n data matrices.
#' @param dataname Vector of data matrix names.
#' @param outMap List mapping between block index set and estimated partially shared structure.
#' @param keyIdxMap List mapping between joint block index and data blocks.
#' @param jointBlockOrder Vector to record the joint block order.
#' @param doubleCenter Flag indicating whether to perform double centering.
#'
#' @return A list containing the joint basis map, loadings, and joint blocks.
#' @export
DJIVEReconstructMJ <- function(datablock, dataname, outMap, keyIdxMap, jointBlockOrder, doubleCenter) {
  nb <- length(datablock)
  matJointV <- vector("list", nb)
  matJointOrder <- vector("list", nb)
  matJointRanks <- vector("list", nb)

  # # Initialize joint basis, order, and ranks
  # for (ib in seq_len(nb)) {
  #   matJointV[[ib]] <- matrix()
  #   matJointOrder[[ib]] <- character()
  #   matJointRanks[[ib]] <- numeric()
  # }

  for (ib in seq_len(nb)) {
    #matJointV[[ib]] <- matrix(NA, nrow = 1, ncol = 1)  # double check when data change
    matrix(nrow = nrow(datablock[[ib]]), ncol = 0)
    matJointOrder[[ib]] <- character()
    matJointRanks[[ib]] <- numeric()
  }

  # print(matJointV)
  #print(dim(matJointV))

  # Re-rotate joint bases for interpretation
  commonNormalizedBasisMap <- list()
  for (idx in 1:(2^nb - 1)) {
    idxStr <- as.character(idx)
    if (idxStr %in% names(outMap)) {
      blockIn <- keyIdxMap[[idxStr]]
      jointSpace <- outMap[[idxStr]]
      jointSpaceProj <- jointSpace %*% t(jointSpace)
      jointDim <- ncol(jointSpace)
      dataStack <- do.call(rbind, datablock[blockIn])
      commonNormalizedBasisMap[[idxStr]] <- svds(dataStack %*% jointSpaceProj, jointDim)$v
    }
  }
  outMapRaw <- outMap
  outMap <- commonNormalizedBasisMap
  #print(dim(outMap))
  # Collect joint block basis for each data matrix
  for (i in seq_along(jointBlockOrder)) {
    t <- jointBlockOrder[[i]]
    V <- outMap[[t]]

    # print(V)
    # print(dim(V))
    #print(matJointV)
    #print(dim(matJointV))

    r <- ncol(V)
    blockIdx <- keyIdxMap[[t]]
    cat(sprintf("The rank of joint block among %s: %d\n", paste(dataname[blockIdx], collapse = ", "), r))
    for (ib in blockIdx) {
      matJointV[[ib]] <- cbind(matJointV[[ib]], V)
      matJointOrder[[ib]] <- c(matJointOrder[[ib]], t)
      matJointRanks[[ib]] <- c(matJointRanks[[ib]], r)
    }
  }

  # Calculate the loadings and the joint block in each data matrix
  matLoadings <- vector("list", nb)
  matBlocks <- vector("list", nb)
  for (ib in seq_len(nb)) {
    datablockc <- datablock[[ib]]
    if (doubleCenter == 1) {
      bsize <- dim(datablock[[ib]])
      d <- bsize[1]
      n <- bsize[2]
      datablockc <- datablock[[ib]] - rowMeans(datablock[[ib]]) - matrix(colMeans(datablock[[ib]]), nrow = d, ncol = n, byrow = TRUE) + mean(datablock[[ib]])
    }
    res <- MatReconstructMJ(datablockc, matJointV[[ib]], matJointOrder[[ib]], matJointRanks[[ib]])
    matBlocks[[ib]] <- res$matBlockMap
    matLoadings[[ib]] <- res$matLoadingMap
  }

  # Output structure
  outstruct <- list(
    jointBasisMap = outMap,
    matLoadings = matLoadings,
    matBlocks = matBlocks,
    keyIdxMap = keyIdxMap
  )
  return(outstruct)
}
