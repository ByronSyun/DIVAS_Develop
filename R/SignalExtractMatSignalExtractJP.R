#' Matrix Signal Extraction
#'
#' The `MatSignalExtractJP` function performs signal extraction from a data matrix to estimate the signal rank, signal row space, corresponding perturbation angles, and noise matrix. It adjusts the signals based on random direction angles and uses bootstrap estimation to refine the results.
#'
#' @param X A numeric matrix (d x n) containing the data to be analyzed. Must not contain any `NA` values.
#' @param matName A string representing the name of the matrix, used for logging purposes.
#' @param nsim An integer specifying the number of bootstrap samples to be used during the estimation process.
#' @param colCent A logical value indicating whether to center the columns of the matrix. Default is `FALSE`.
#' @param rowCent A logical value indicating whether to center the rows of the matrix. Default is `FALSE`.
#' @param cull A numeric value controlling the culling process during signal extraction. Default is `0.5`.
#' @param percentile A numeric value representing the percentile for estimating the noise level.
#' @param noiselvl Optional. A noise level parameter that can be either a numeric value or 'ks' to use the `ksOpt` function for noise level estimation. If not provided, an optimal shrinkage method will be used.
#'
#' @return A list containing:
#' \describe{
#'   \item{VBar}{Matrix representing the adjusted signal row space.}
#'   \item{UBar}{Matrix representing the adjusted signal column space.}
#'   \item{phiBar}{Numeric value of the adjusted perturbation angle.}
#'   \item{psiBar}{Numeric value of the loadings perturbation angle.}
#'   \item{rBar}{Integer representing the adjusted signal rank.}
#'   \item{EHat}{Matrix representing the estimated noise.}
#'   \item{singVals}{Vector of singular values before shrinkage.}
#'   \item{singValsHat}{Vector of singular values after shrinkage.}
#'   \item{rSteps}{List of steps used in signal rank adjustment.}
#'   \item{VVHatCacheBar}{List of matrices from bootstrap validation steps.}
#'   \item{UUHatCacheBar}{List of matrices from bootstrap validation steps.}
#' }
#'
#' @importFrom RSpectra svds
#' @export
#'
MatSignalExtractJP <- function(
    X, matName = NULL, nsim = 400, colCent = F, rowCent = F,
    cull = 0.382, percentile = 0.5, noiselvl = NULL
  ) {


  if (!is.numeric(X)) {
    stop("The input matrix X is not numeric.")
  }
  if (any(is.na(X))) {
    stop("The input matrix X contains NA values.")
  }

  d <- nrow(X)
  n <- ncol(X)
  if (is.null(d) || is.null(n)) {
    stop("The input matrix X has invalid dimensions.")
  }

  mindn <- min(d, n)

  if(is.null(matName)) matName <- "datablock"

  #Perform SVD on the data matrix X
  svdResult <- La.svd(X)
  UFull <- svdResult$u
  singVals <- svdResult$d
  singVals <- matrix(singVals, nrow = length(singVals), ncol = 1)
  #singVals <- diag(as.vector(singVals))
  VFull <- t(svdResult$vt)

  beta <- min(n/d, d/n)


  # Singlular value shrinkage
  if (is.null(noiselvl)) {
    # If `noiselvl` is not provided, estimate it using optimal shrinkage
    result <- optimal_shrinkage(singVals, beta, 'op', percentile)
    singValsHat <- result$singvals
    noiselvl <- result$noiselvl
  } else {
    if (noiselvl == 'ks') {
      # If `noiselvl` is set to 'ks', use the ksOpt function to determine the noise level
      noiselvl <- ksOpt(singVals, beta)
    }
    singValsHat <- optimal_shrinkage(singVals, beta, 'op', noiselvl)$singvals
  }

  # Rank estimate
  rHat <- sum(singValsHat > 0)
  cat(sprintf('Initial signal rank for %s is %d.\n', matName, rHat))

  recovBound <- noiselvl * (1 + sqrt(beta))

  # SVD after shrinkage
  # svdHat <- RSpectra::svds(X, rHat)
  # UHat <- svdHat$u
  # VHat <- svdHat$v
  UHat <- UFull[, 1:rHat, drop=F]
  VHat <- VFull[, 1:rHat, drop=F]
  singValsTilde <- singValsHat[1:rHat]
  AHat <- UHat %*% diag(x = singValsTilde, nrow = length(singValsTilde)) %*% t(VHat)
  EHat <- X - AHat

  EHatGood <- UFull[, (rHat+1):mindn] %*% diag(singVals[(rHat+1):mindn], nrow = length(singVals[(rHat+1):mindn])) %*% t(VFull[, (rHat+1):mindn])
  XRemaining <- X - EHatGood

  # Imputation of missing energy
  imputedSingVals <- numeric(rHat)
  for (iter in 1:rHat) {
    perc <- stats::runif(1)
    marpas <- PercentileMarcenkoPastur(beta, perc)
    imputedSingVals[iter] <- sqrt(marpas)
  }

  inflatedImpSingVals <- imputedSingVals * noiselvl
  EHatImpute <- EHatGood + UHat %*% diag(inflatedImpSingVals, nrow = length(inflatedImpSingVals)) %*% t(VHat)

  randAngleCache <- randDirAngleMJ(n, rHat, 1000)
  randAngleCacheLoad <- randDirAngleMJ(d, rHat, 1000)
  randAngle <- stats::quantile(randAngleCache, 0.05)
  randAngleLoad <- stats::quantile(randAngleCacheLoad, 0.05)

  rSteps <- rHat

  # Bootstrap estimation and signal rank adjustment by removing PCs with perturbation angle larger
  # than half the value of random direction angle
  PCAnglesCacheFullBoot <- matrix(90, nsim, rHat)
  PCAnglesCacheFullBootLoad <- matrix(90, nsim, rHat)

  cat('Progress Through Bootstrapped Matrices:\n')
  cat(paste0('\n', strrep('.', nsim), '\n\n'))

  for (s in 1:nsim) {
    randV <- matrix(stats::rnorm(n * rHat), n, rHat)
    if(colCent) randV <- MatCenterJP(randV, iColCent = T)
    randV <- qr.Q(qr(randV))

    randU <- matrix(stats::rnorm(d * rHat), d, rHat)

    #print(dim(randV))
    if (rowCent) randU <- MatCenterJP(randU, iRowCent = T)
    randU <- qr.Q(qr(randU))
    randX <- randU %*% diag(singValsTilde, nrow = length(singValsTilde)) %*% t(randV) + EHatImpute
    svdRand <- RSpectra::svds(randX, rHat)
    randUHat <- svdRand$u
    randVHat <- svdRand$v
    # for (j in 1:rHat) {
    #   PCAnglesCacheFullBoot[s, j] <- acosd(min(svd(t(randV) %*% randVHat[, 1:j])))
    #   PCAnglesCacheFullBootLoad[s, j] <- acosd(min(svd(t(randU) %*% randUHat[, 1:j])))
    # }
    # Correcting the angle calculation
    for (j in 1:rHat) {
      svd_randV <- svd(t(randV) %*% randVHat[, 1:j])
      PCAnglesCacheFullBoot[s, j] <- acosd(min(svd_randV$d))  # Extract singular values from svd_randV$d

      svd_randU <- svd(t(randU) %*% randUHat[, 1:j])
      PCAnglesCacheFullBootLoad[s, j] <- acosd(min(svd_randU$d))  # Extract singular values from svd_randU$d
    }

    cat('\b|\n')
  }
  # cat('size of randV2')
  # print(dim(randV))
  # cat('size of PCAnglesCacheFullBootLoad')
  # print(dim(PCAnglesCacheFullBootLoad))
  # print(PCAnglesCacheFullBoot[12,12])
  # print(PCAnglesCacheFullBootLoad[12,12])
  #
  # cat('randAngle dimension and randAngle\n')
  # print(dim(randAngle))
  # print(randAngle)
  # print(as.numeric(randAngle))
  # print(dim(as.numeric(randAngle)))

  randAngle <- as.numeric(randAngle)
  # randAngle <- matrix(randAngle, nrow = 1, ncol = 1)
  # cat('randAngle dimension and randAngle\n')
  # print(dim(randAngle))
  # print(randAngle)
  #
  cull <- as.numeric(cull)
  # cat('cull dimension and cull\n')
  # print(dim(cull))

  # cat('randAngle * culll\n')
  # print(randAngle * cull)
  #
  # cat('cull\n')
  # print(cull)
  #
  # cat('quantile(PCAnglesCacheFullBoot, 0.95, 1)\n')

  rBar_quantiles <- apply(PCAnglesCacheFullBoot, 2, stats::quantile, probs = 0.95)
  # print(dim(rBar_quantiles))
  rBarLoad_quantiles <- apply(PCAnglesCacheFullBootLoad, 2, stats::quantile, probs = 0.95)
  rBar <- sum(rBar_quantiles < as.numeric(randAngle * cull))
  #rBar <-3
  rBarLoad <- sum(rBarLoad_quantiles < as.numeric(randAngleLoad * cull))

  #######
  # cat('rBar')
  # print(rBar)
  # cat('rBarLoad is ',rBarLoad, '\n')

  cat(sprintf('Culled Rank is %d.\n', rBar))

  # validPC <- quantile(PCAnglesCacheFullBoot, 0.95, 1) < randAngle * cull
  quantiles_validPC <- apply(PCAnglesCacheFullBoot, 2, stats::quantile, probs = 0.95)
  validPC <- quantiles_validPC < as.numeric(randAngle * cull)

  # cat('quantiles_validPC is ',quantiles_validPC, '\n')
  # cat('quantiles_validPC dim is ',dim(quantiles_validPC), '\n')
  # cat('randAngle * cull dim is ',dim(randAngle * cull), '\n')
  #
  #validPC <- quantiles_validPC < randAngle * cull
  #cat('validPC is ',validPC, '\n')

  minInd <- which.min(stats::quantile(PCAnglesCacheFullBoot, 0.95, 1))
  minInd <- as.numeric(minInd)
  # cat("minInd\n")
  # print(as.numeric(minInd))
  #

  validPC[minInd] <- TRUE
  rBar <- sum(validPC)
  phiBar <- stats::quantile(PCAnglesCacheFullBoot[, rBar], 0.95)
  psiBar <- stats::quantile(PCAnglesCacheFullBootLoad[, rBar], 0.95)


  ## TODO: not used later, consider deleting
  VVHatCacheBar <- vector("list", nsim)
  UUHatCacheBar <- vector("list", nsim)
  singValsTildeBar <- singValsTilde[1:rBar]
  for (s in 1:nsim) {
    randV <- matrix(stats::rnorm(n * rBar), n, rBar)
    if (colCent) randV <- MatCenterJP(randV, iColCent = T)
    randV <- qr.Q(qr(randV))
    randU <- matrix(stats::rnorm(d * rBar), d, rBar)
    if (rowCent) randU <- MatCenterJP(randU, iRowCent = T)
    randU <- qr.Q(qr(randU))
    randX <- randU %*% diag(singValsTildeBar, nrow = length(singValsTildeBar)) %*% t(randV) + EHat
    svdRand <- RSpectra::svds(randX, rBar)
    randUHat <- svdRand$u
    randVHat <- svdRand$v
    VVHatCacheBar[[s]] <- t(randV) %*% randVHat
    UUHatCacheBar[[s]] <- t(randU) %*% randUHat
  }

  # Final Outputs
  VBar <- VHat[, validPC]
  UBar <- UHat[, validPC]

  cat(sprintf('Perturbation Angle for %s is %.1f.\n', matName, phiBar))

  return(list(VBar = VBar, UBar = UBar, phiBar = phiBar, psiBar = psiBar, rBar = rBar,
              EHat = EHat, singVals = singVals, singValsHat = singValsHat, rSteps = rSteps,
              VVHatCacheBar = VVHatCacheBar, UUHatCacheBar = UUHatCacheBar))
}



#
# ####################################test######################################
# # from Matlab rng42
# library(R.matlab)
# data <- readMat('/Users/byronsun/Desktop/RA_Mao/R code DIVAS/MatSignalExtract_matrix2.mat')
# X <- data$X
#
# # cat("First element:", X[1, 1], "\n")
# # cat("Element at (20, 20):", X[20, 20], "\n")
# # svdResult <- La.svd(X)
# # UFull <- svdResult$u
# # singVals <- svdResult$d
# # singVals <- matrix(singVals, nrow = length(singVals), ncol = 1)
# # singVals <- diag(as.vector(singVals))
# # VFull <- t(svdResult$vt)
#
# #
# # cat("size of UFull:\n")
# # print(dim(UFull))
# # cat("size of VFull:\n")
# # print(dim(VFull))
# # cat("First element VFull:", VFull[1, 1], "\n")
# # cat("Element at (20, 20) VFull:", VFull[200, 199], "\n")
# #
# #
#
#
# #cat("First 5 rows of X:\n")
# #print(head(X,1))
#
# matName = 'datablock1';
# nsim = 400;
# colCent = 0;
# rowCent = 0;
# cull = 0.5;
# percentile = 0.3825;
#
#
# result <- MatSignalExtractJP(X, matName, nsim, colCent, rowCent, cull, percentile)
#
# cat("Results from MatSignalExtractJP in R:\n")
# cat("Adjusted signal rank (rBar):", result$rBar, "\n")
# cat("Perturbation angle (phiBar):", result$phiBar, "\n")
# cat("Loadings perturbation angle (psiBar):", result$psiBar, "\n")
# cat("Singular values before shrinkage:\n")
# print(t(result$singVals))
# cat("Singular values after shrinkage:\n")
# print(t(result$singValsHat))
#
# zero_count <- sum(t(result$singValsHat) == 0)
# cat("Number of zeros in the matrix:", zero_count, "\n")
# cat("dim of singValsHat:", dim(result$singValsHat), "\n")
