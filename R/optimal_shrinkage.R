#' Optimal Shrinkage of Singular Values
#'
#' The `optimal_shrinkage` function performs optimal shrinkage of singular values based on the specified loss function and estimated noise level. The function supports three types of loss functions: Frobenius ("fro"), operator norm ("op"), and nuclear norm ("nuc").
#'
#' @param singvals A numeric vector of singular values to be shrunk.
#' @param beta A numeric value representing the ratio of dimensions (min(n, d) / max(n, d)), where n and d are the dimensions of the matrix.
#' @param loss A string specifying the loss function to be used for shrinkage. Options are "fro" (Frobenius norm), "op" (operator norm), and "nuc" (nuclear norm).
#' @param percentile A numeric value representing the percentile used for noise level estimation if `sigma` is not provided.
#' @param sigma Optional. A numeric value representing the noise level. If not provided, it will be estimated using the Median Marcenko-Pastur distribution.
#'
#' @return A list containing:
#' \describe{
#'   \item{singvals}{The shrunk singular values as a numeric vector.}
#'   \item{noiselvl}{The estimated noise level used in the shrinkage process.}
#' }
#'
#' @export
#'
optimal_shrinkage <- function(singvals, beta, loss, percentile, sigma) {
  # similar to MATLAB assertions
  stopifnot(length(beta) == 1)
  stopifnot(beta <= 1)
  stopifnot(beta > 0)
  stopifnot(length(singvals) == length(singvals))
  stopifnot(loss %in% c("fro", "op", "nuc"))

  # Estimate sigma if needed
  #if nargin<5
  # warning('off','MATLAB:quadl:MinStepSize')''
  if (missing(sigma) ||is.null(sigma)) {
    MPmedian <- MedianMarcenkoPastur(beta)
    sigma <- quantile(singvals, probs = percentile) / sqrt(MPmedian)
    cat(sprintf("estimated noise = %0.2f \n", sigma))
  }

  singvals <- optshrink_impl(singvals, beta, loss, sigma)
  noiselvl <- sigma

  return(list(singvals = singvals, noiselvl = noiselvl))
}





# function I = MarcenkoPasturIntegral(x, beta)
# if beta <= 0 || beta > 1
# error('beta beyond')
# end
# lobnd = (1 - sqrt(beta))^2;
# hibnd = (1 + sqrt(beta))^2;
# if (x < lobnd) || (x > hibnd)
# error('x beyond')
# end
# dens = @(t) sqrt((hibnd-t).*(t-lobnd))./(2*pi*beta.*t);
# I = integral(dens,lobnd,x);
# fprintf('x=%.3f,beta=%.3f,I=%.3f\n',x,beta,I);
# end







# incMarPas <- function(x0, beta, gamma) {
#   if (beta > 1) stop("beta beyond")
#
#   topSpec <- (1 + sqrt(beta))^2
#   botSpec <- (1 - sqrt(beta))^2
#   MarPas <- function(x) ifelse((topSpec - x) * (x - botSpec) > 0,
#                                sqrt((topSpec - x) * (x - botSpec)) / (beta * x) / (2 * pi),
#                                0)
#
#   if (gamma != 0) {
#     fun <- function(x) (x^gamma * MarPas(x))
#   } else {
#     fun <- MarPas
#   }
#
#   I <- integrate(fun, x0, topSpec)$value
#   return(I)
# }





####################################test######################################
# # from Matlab rng42
# library(R.matlab)
# data <- readMat('optimal_shrinkage_random_matrix.mat')
# X <- data$X
#
# svd_result <- svd(X)
# singvals <- svd_result$d
# beta <-  ncol(X)/nrow(X)
# percentile <- 0.9
# sigma <- 0.5
#
# # Apply op shrinkage
# result <- optimal_shrinkage(singvals, beta, loss = "op", percentile = percentile, sigma = sigma)
#
# cat("Original Singular Values:\n")
# print(singvals)
# cat("Shrunk Singular Values:\n")
# print(result$singvals)
# cat("Estimated Noise Level:\n")
# print(result$noiselvl)

