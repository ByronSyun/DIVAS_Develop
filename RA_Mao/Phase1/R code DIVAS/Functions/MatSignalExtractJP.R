MatSignalExtractJP <- function(X, matName, nsim, colCent = FALSE, rowCent = FALSE, cull = 0.5, percentile = 0.05, noiselvl = NULL) {
  # MatSignalExtractJP   Matrix signal extraction
  #   Estimate signal rank, signal row space, corresponding perturbation
  #   angle and noise matrix. Adjust signals based on random direction angle.
  #
  # Inputs:
  #   X - d x n data matrix
  #   matName - string of matrix name
  #   nsim - number of bootstrap samples
  #
  # Outputs:
  #   VBar - adjusted signal row space
  #   phiBar - adjusted perturbation angle
  #   rBar - adjusted signal rank
  #   EHat - estimated noise matrix
  
  d <- nrow(X)
  n <- ncol(X)
  mindn <- min(d, n)
  
  svd_result <- svd(X)
  UFull <- svd_result$u
  singVals <- svd_result$d
  VFull <- svd_result$v
  
  beta <- min(n / d, d / n)
  
  if (is.null(noiselvl)) {
    result <- optimal_shrinkage(singVals, beta, 'op', percentile)
    singValsHat <- result$singValsHat
    noiselvl <- result$noiselvl
  } else {
    if (noiselvl == 'ks') {
      noiselvl <- ksOpt(singVals, beta)
    }
    singValsHat <- optimal_shrinkage(singVals, beta, 'op', noiselvl)$singValsHat
  }
  
  rHat <- sum(singValsHat > 0)
  cat(sprintf("Initial signal rank for %s is %d.\n", matName, rHat))
  recovBound <- noiselvl * (1 + sqrt(beta))
  
  svds_result <- svd(X, rHat)
  UHat <- svds_result$u
  VHat <- svds_result$v
  singValsTilde <- singValsHat[1:rHat]
  
  AHat <- UHat %*% diag(singValsTilde) %*% t(VHat)
  EHat <- X - AHat
  EHatGood <- UFull[, (rHat + 1):mindn] %*% diag(singVals[(rHat + 1):mindn]) %*% t(VFull[, (rHat + 1):mindn])
  XRemaining <- X - EHatGood
  
  imputedSingVals <- numeric(rHat)
  for (iter in seq_len(rHat)) {
    perc <- runif(1)
    marpas <- PercentileMarcenkoPastur(beta, perc)
    imputedSingVals[iter] <- sqrt(marpas)
  }
  
  EHatImpute <- EHatGood + UHat %*% diag(imputedSingVals * noiselvl) %*% t(VHat)
  
  randAngleCache <- randDirAngleMJ(n, rHat, 1000)
  randAngleCacheLoad <- randDirAngleMJ(d, rHat, 1000)
  randAngle <- quantile(randAngleCache, 0.05)
  randAngleLoad <- quantile(randAngleCacheLoad, 0.05)
  
  # bootstrap estimation
  rSteps <- rHat
  
  PCAnglesCacheFullBoot <- matrix(90, nrow = nsim, ncol = rHat)
  PCAnglesCacheFullBootLoad <- matrix(90, nrow = nsim, ncol = rHat)
  
  cat('Progress Through Bootstraped Matrices:\n')
  
  for (s in seq_len(nsim)) {
    randV <- matrix(rnorm(n * rHat), n, rHat)
    if (colCent) {
      randV <- scale(randV, center = TRUE, scale = FALSE)
    }
    randV <- svd(randV)$u
    
    randU <- matrix(rnorm(d * rHat), d, rHat)
    if (rowCent) {
      randU <- scale(randU, center = TRUE, scale = FALSE)
    }
    randU <- svd(randU)$u
    
    randX <- randU %*% diag(singValsTilde) %*% t(randV) + EHatImpute
    
    svds_result <- svd(randX, rHat)
    randUHat <- svds_result$u
    randVHat <- svds_result$v
    
    for (j in seq_len(rHat)) {
      PCAnglesCacheFullBoot[s, j] <- acosd(min(svd(randV %*% randVHat[, seq_len(j)])$d))
      PCAnglesCacheFullBootLoad[s, j] <- acosd(min(svd(randU %*% randUHat[, seq_len(j)])$d))
    }
    
    cat('|')
  }
  
  rBar <- sum(quantile(PCAnglesCacheFullBoot, 0.95, 1) < randAngle * cull)
  rBarLoad <- sum(quantile(PCAnglesCacheFullBootLoad, 0.95, 1) < randAngleLoad * cull)
  
  cat(sprintf("Culled Rank is %d.\n", rBar))
  
  validPC <- quantile(PCAnglesCacheFullBoot, 0.95, 1) < randAngle * cull
  minInd <- which.min(quantile(PCAnglesCacheFullBoot, 0.95, 1))
  validPC[minInd] <- TRUE
  rBar <- sum(validPC)
  phiBar <- quantile(PCAnglesCacheFullBoot[, rBar], 0.95)
  psiBar <- quantile(PCAnglesCacheFullBootLoad[, rBar], 0.95)
  
  VVHatCacheBar <- vector("list", nsim)
  UUHatCacheBar <- vector("list", nsim)
  singValsTildeBar <- singValsTilde[1:rBar]
  
  for (s in seq_len(nsim)) {
    randV <- matrix(rnorm(n * rBar), n, rBar)
    if (colCent) {
      randV <- scale(randV, center = TRUE, scale = FALSE)
    }
    randV <- svd(randV)$u
    
    randU <- matrix(rnorm(d * rBar), d, rBar)
    if (rowCent) {
      randU <- scale(randU, center = TRUE, scale = FALSE)
    }
    randU <- svd(randU)$u
    
    randX <- randU %*% diag(singValsTildeBar) %*% t(randV) + EHat
    
    svds_result <- svd(randX, rBar)
    randUHat <- svds_result$u
    randVHat <- svds_result$v
    
    VVHatCacheBar[[s]] <- t(randV) %*% randVHat
    UUHatCacheBar[[s]] <- t(randU) %*% randUHat
  }
  
  VBar <- VHat[, validPC]
  UBar <- UHat[, validPC]
  
  cat(sprintf("Perturbation Angle for %s is %.1f.\n", matName, phiBar))
  
  return(list(VBar = VBar, UBar = UBar, phiBar = phiBar, psiBar = psiBar, rBar = rBar, EHat = EHat, singVals = singVals, singValsHat = singValsHat, rSteps = rSteps, VVHatCacheBar = VVHatCacheBar, UUHatCacheBar = UUHatCacheBar))
}

