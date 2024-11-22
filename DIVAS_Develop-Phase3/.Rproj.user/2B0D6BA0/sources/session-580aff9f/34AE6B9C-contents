#' MatReconstructMJ - Reconstruct joint block matrices and their loadings from data
#'
#' @param X d x n data matrix
#' @param matJointV n x sum(r_t) joint structure basis matrix
#' @param matJointOrder List that keeps the order of joint blocks in matJointV
#' @param matJointRanks Vector containing the rank of each joint block in matJointV
#'
#' @return A list containing `matBlockMap` (joint block matrix map) and `matLoadingMap` (joint block loading map)
#' @export
#'
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
