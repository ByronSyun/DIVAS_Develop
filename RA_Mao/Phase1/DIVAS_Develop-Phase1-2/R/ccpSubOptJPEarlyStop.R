#' CCP Sub-Optimization for Joint Penalty with Early Stop
#'
#' This function performs a sub-optimization using CVXR for penalty-based joint optimization.
#' It formulates and solves a convex optimization problem with quadratic objectives and constraints.
#'
#' @param v0 A numeric vector; the initial direction.
#' @param Qo1 A matrix representing the first quadratic form in the objective function.
#' @param Qo2 A matrix representing the second quadratic form in the objective function.
#' @param Qc1 A list of matrices representing the first quadratic form in the constraints.
#' @param Qc2 A list of matrices representing the second quadratic form in the constraints.
#' @param Vo A matrix representing orthogonal constraints.
#' @param tau A numeric value representing the multiplier of slack variables.
#'
#' @return A list containing:
#'   \item{v}{The optimized direction vector.}
#'   \item{slack}{The optimized slack variable values.}
#'   \item{objval}{The final objective value of the optimization problem.}
#' @importFrom CVXR Variable Problem Minimize solve quad_form sum_squares
#' @export
ccpSubOptJPEarlyStop <- function(v0, Qo1, Qo2, Qc1, Qc2, Vo, tau) {
  # Inputs validation
  if (!is.numeric(v0)) stop("v0 must be a numeric vector.")
  if (!is.matrix(Qo1) || !is.matrix(Qo2)) stop("Qo1 and Qo2 must be matrices.")
  if (!is.list(Qc1) || !is.list(Qc2)) stop("Qc1 and Qc2 must be lists of matrices.")
  if (!is.matrix(Vo)) stop("Vo must be a matrix.")
  if (!is.numeric(tau) || length(tau) != 1) stop("tau must be a single numeric value.")

  nc <- length(Qc1)
  n <- length(v0)
  ro <- ncol(Vo)

  # Define variables
  v <- Variable(n)
  slack <- Variable(nc + 2)

  # Define the objective function
  objective <- quad_form(v, Qo1) - 2 * t(v0) %*% Qo2 %*% v + quad_form(v0, Qo2) + tau * sum(slack)

  # Define the constraints
  constraints <- list()
  for (ic in 1:nc) {
    constraints <- c(constraints,
                     quad_form(v, Qc1[[ic]]) - 2 * t(v0) %*% Qc2[[ic]] %*% v + quad_form(v0, Qc2[[ic]]) <= slack[ic])
  }
  constraints <- c(constraints,
                   sum_squares(v) - 1 <= slack[nc + 1],
                   1 - 2 * t(v0) %*% v + sum_squares(v) <= slack[nc + 2],
                   slack >= 0,
                   t(Vo) %*% v == matrix(0, nrow = ro, ncol = 1))

  # Define the optimization problem
  problem <- Problem(Minimize(objective), constraints)

  # Solve the problem
  result <- solve(problem)

  # Extract the results
  v_opt <- result$getValue(v)
  slack_opt <- result$getValue(slack)
  cvx_objval <- t(v_opt) %*% Qo1 %*% v_opt - 2 * t(v0) %*% Qo2 %*% v_opt + t(v0) %*% Qo2 %*% v0

  # Return the results as a list
  return(list(v = v_opt, slack = slack_opt, objval = cvx_objval))
}
