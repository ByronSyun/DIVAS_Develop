#' Analyze Optimization Output by Calculating Projection Angles
#'
#' The function `ccpOutAnalysisMJ` computes the projected angles between each cached optimization vector
#' and each adjusted signal row space. The projection angle serves as a metric for evaluating alignment
#' between the vectors obtained during optimization and the reference row spaces.
#'
#' @param cache_v A list of optimization vectors obtained from iterations of the optimization algorithm.
#' @param VBars A list of adjusted signal row spaces (matrices).
#'
#' @return A list of length equal to the number of signal row spaces. Each element is a numeric vector of
#' angles for each iteration of the optimization process.
#'
#' @export
ccpOutAnalysisMJ <- function(cache_v, VBars) {
  # Number of adjusted signal row spaces
  nb <- length(VBars)
  # Number of cached optimization vectors
  T <- length(cache_v)
  # Initialize angleHats as a list to store results
  angleHats <- vector("list", nb)

  # Loop over each adjusted signal row space
  for (ib in 1:nb) {
    # Initialize angles vector with -1 for each iteration (default initialization)
    angles <- rep(-1, T)

    # Loop over each cached optimization vector to compute the projection angle
    for (t in 1:T) {
      # Calculate the projected angle of each vector on the row space
      angles[t] <- projAngleMJ(cache_v[[t]], VBars[[ib]])
    }

    # Store the calculated angles in the angleHats list
    angleHats[[ib]] <- angles
  }

  return(angleHats)
}
