randDirAngleMJ <- function(n, r, nsim) {
  # randDirAngleMJ   calculate random direction angle
  #   Simulate the angles between a random direction and a fixed rank r 
  #   subspace in R^n (in this case the subspace of the first r dimensions).
  #
  # Inputs:
    #   n - dimension of vector space
  #   r - dimension of subspace
  #   nsim - number of simulation samples
  #
  # Outputs:
  #   angles - nsim x 1 simulated random direction angles
  angles <- numeric(nsim)
  
  for (i in 1:nsim) {
    vec <- rnorm(n)
    angles[i] <- acos(sum(vec[1:r]^2)^0.5 / sum(vec^2)^0.5) * 180 / pi
  }
  return(angles)
}
