#' Penalty CCP Joint Penalty with Early Stop Optimization
#'
#' This function performs optimization using a penalty-based CCP (Convex Concave Procedure)
#' to estimate joint structures in high-dimensional data with an early stop mechanism.
#'
#' @param v0 A numeric vector; the initial direction.
#' @param Qo1 A matrix representing the first quadratic form in the objective function.
#' @param Qo2 A matrix representing the second quadratic form in the objective function.
#' @param Qc1 A list of matrices representing the first quadratic form in the constraints.
#' @param Qc2 A list of matrices representing the second quadratic form in the constraints.
#' @param Vorth A matrix of orthogonal constraints.
#' @param optArgin A list of optimization tuning parameters: \code{tau0}, \code{tau_max},
#'   \code{mu}, \code{t_max}, \code{tol}, \code{delta}. Default values are used if not provided.
#'
#' @return A list with the following components:
#'   \item{opt_v}{The optimized direction vector.}
#'   \item{cache_v}{Cache of all vectors from each iteration.}
#'   \item{cache_cvx_objval}{Cache of objective values from each iteration.}
#'   \item{cache_slack}{Cache of slack variable values from each iteration.}
#'   \item{converge}{Flag indicating if the optimization converged.}
#' @importFrom CVXR Variable Problem Minimize solve quad_form sum_squares
#' @export
penaltyCCPJPEarlyStop <- function(v0, Qo1, Qo2, Qc1, Qc2, Vorth, optArgin = list()) {

  # Default optimization parameters
  optargs <- list(0.5, 1000, 1.05, 200, 1e-3, 1e-3)

  # Update with user-provided arguments if available
  numvarargs <- length(optArgin)
  if (numvarargs > 0) {
    optargs[1:numvarargs] <- optArgin
  }

  # Assign optimization parameters
  tau0 <- optargs[[1]]
  tau_max <- optargs[[2]]
  mu <- optargs[[3]]
  t_max <- optargs[[4]]
  tol <- optargs[[5]]
  delta <- optargs[[6]]

  # Ensure Vorth is valid
  if (nrow(Vorth) == 0) {
    Vorth <- matrix(0, nrow(Qo1), 1)
  }

  # Initialize caches for optimization
  cache_v <- vector("list", t_max)
  cache_cvx_objval <- rep(Inf, t_max)
  cache_slack <- vector("list", t_max)

  # Set initial values
  cache_v[[1]] <- v0
  nc <- length(Qc1)
  cache_slack[[1]] <- rep(Inf, nc + 2)
  converge <- 0
  tau <- tau0

  updatePrintFormat <- paste0("%d ", paste(rep("%f ", length(Qc1) + 3), collapse = ""), "\n")

  # Main optimization loop
  for (t in 2:t_max) {
    if (t %% 10 == 0) {
      cat(sprintf("Iteration %d\n", t))
    }

    # Call the optimization sub-function
    result_penalty <- ccpSubOptJPEarlyStop(cache_v[[t - 1]], Qo1, Qo2, Qc1, Qc2, Vorth, tau)

    # Safety check before accessing the result
    if (!is.null(result_penalty$v) && length(result_penalty$v) > 0) {
      cache_v[[t]] <- result_penalty$v
    } else {
      cat(sprintf("Iteration %d - Solver returned an invalid value. Skipping.\n", t))
      break
    }

    # Store slack and objective values
    cache_slack[[t]] <- result_penalty$slack
    cache_cvx_objval[t] <- result_penalty$objval

    # Check for NaNs in the solution
    if (any(is.na(cache_v[[t]]))) {
      cat(sprintf("NaN solution appears in iteration %d\n", t))
      break
    }

    # Normalize the vector
    cache_v[[t]] <- cache_v[[t]] / norm(cache_v[[t]], "2")

    # Compute current and previous objective values
    curr_objval <- cache_cvx_objval[t] + tau * sum(cache_slack[[t]])
    if (is.infinite(cache_cvx_objval[t - 1])) {
      pre_objval <- 1e6  # Assign a large finite value if the first value is Inf
    } else {
      pre_objval <- cache_cvx_objval[t - 1] + (tau / mu) * sum(cache_slack[[t - 1]])
    }

    # Print the current slack variables and objective difference
    cat(do.call(sprintf, c(list(updatePrintFormat, t), as.list(cache_slack[[t]]), list(curr_objval - pre_objval))))

    # Check convergence based on objective value change and slack variables
    if (norm(curr_objval - pre_objval, type = "2") < tol && sum(cache_slack[[t]]) <= delta) {
      if (converge == 1) {
        break
      } else {
        converge <- 1
      }
    } else {
      converge <- 0
    }

    # Update tau for the next iteration
    tau <- min(mu * tau, tau_max)
  }

  # Truncate cache variables to the actual number of iterations
  cache_v <- cache_v[1:t]
  cache_cvx_objval <- cache_cvx_objval[1:t]
  cache_slack <- cache_slack[1:t]

  # Return the results
  return(list(opt_v = cache_v[[t]], cache_v = cache_v, cache_cvx_objval = cache_cvx_objval, cache_slack = cache_slack, converge = converge))
}
