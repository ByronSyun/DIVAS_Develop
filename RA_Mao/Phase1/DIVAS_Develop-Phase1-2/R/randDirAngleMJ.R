#' Simulate Random Direction Angles in Vector Space
#'
#' This function simulates the angles between a random direction and a fixed rank `r` subspace in \eqn{R^n}.
#' Specifically, it calculates the angles between a random vector and the subspace spanned by the first `r`
#' dimensions in an \eqn{n}-dimensional space.
#'
#' @param n An integer representing the dimension of the vector space.
#' @param r An integer representing the dimension of the subspace.
#' @param nsim An integer representing the number of simulation samples.
#'
#' @return A numeric vector of length `nsim`, containing the simulated random direction angles (in degrees).
#'
#' @export
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
