MatSignalExtractMJ <- function(X, matName, nsim) {
  # MatSignalExtractMJ   Matrix signal extraction
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
  
  singVals <- svd(X)$d
  d <- nrow(X)
  n <- ncol(X)
  beta <- min(n/d, d/n)
  optimal_shrinkage_res <- optimal_shrinkage(singVals, beta, loss = 'op')
  singValsHat <- optimal_shrinkage_res$singValsHat
  noiselvl <- optimal_shrinkage_res$noiselvl
  rHat <- sum(singValsHat > 0)
  cat(sprintf("Initial signal rank for %s is %d. \n", matName, rHat))
  recovBound <- noiselvl * (sqrt(d) + sqrt(n))

  
  UHatVHat <- svd(X)
  UHat <- UHatVHat$u[, 1:rHat]
  VHat <- UHatVHat$v[, 1:rHat]
  singValsTilde <- singValsHat[1:rHat]
  AHat <- UHat %*% diag(singValsTilde) %*% t(VHat)
  EHat <- X - AHat
  
  randAngleCache <- randDirAngleMJ(n, rHat, 1000)
  randAngle <- quantile(randAngleCache, 0.05)
  
  # Bootstrap estimation
  VVHatCache <- vector("list", nsim)
  PCAnglesCache <- matrix(90, nrow = nsim, ncol = rHat)
  
  for (i in 1:nsim) {
    randV <- qr.Q(qr(matrix(rnorm(n * rHat), nrow = n)))
    randU <- qr.Q(qr(matrix(rnorm(d * rHat), nrow = d)))
    randX <- randU %*% diag(singValsTilde) %*% t(randV) + EHat
    UHatVHat <- svd(randX)
    randVHat <- UHatVHat$v[, 1:rHat]
    VVHatCache[[i]] <- t(randV) %*% randVHat
    PCAnglesCache[i, ] <- acos(pmin(1, svd(VVHatCache[[i]])$d)) * (180 / pi)
  }
  
  # Adjust signal rank by removing PCs with perturbation angle larger than half value of random direction angle
  PCAngles <- apply(PCAnglesCache, 2, quantile, 0.95)
  validPC <- PCAngles < randAngle / 2
  rBar <- sum(validPC)
  cat(sprintf("Adjusted signal rank for %s is %d. \n", matName, rBar))
  
  VVHatCacheBar <- VVHatCache
  
  while (sum(validPC) < length(validPC)) {
    VVHatCacheBar <- vector("list", nsim)
    PCAnglesCacheBar <- matrix(90, nrow = nsim, ncol = rBar)
    singValsBar <- singValsTilde[validPC]
    
    for (i in 1:nsim) {
      randV <- qr.Q(qr(matrix(rnorm(n * rBar), nrow = n)))
      randU <- qr.Q(qr(matrix(rnorm(d * rBar), nrow = d)))
      randX <- randU %*% diag(singValsBar) %*% t(randV) + EHat
      UHatVHat <- svd(randX)
      randVHat <- UHatVHat$v[, 1:rBar]
      VVHatCacheBar[[i]] <- t(randV) %*% randVHat
      PCAnglesCacheBar[i, ] <- acos(pmin(1, svd(VVHatCacheBar[[i]])$d)) * (180 / pi)
      end
      PCAngles <- apply(PCAnglesCacheBar, 2, quantile, 0.95)
      validPC <- PCAngles < randAngle / 2
      rBar <- sum(validPC)
      cat(sprintf("Adjusted signal rank for %s is %d. \n", matName, rBar))
    }
    
    maxAnglesBar <- maxPerturbAngleMJ(rep(1, rBar), VVHatCacheBar)
    phiBar <- quantile(maxAnglesBar, 0.95)
    VBar <- VHat[, validPC]
    
    cat(sprintf("Perturbation Angle for %s is %.1f. \n", matName, phiBar))
    
    return(list(VBar = VBar, phiBar = phiBar, rBar = rBar, EHat = EHat))
  }
}
  