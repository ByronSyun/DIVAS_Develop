#' Incomplete Marčenko-Pastur Distribution Function
#'
#' Computes the incomplete Marčenko-Pastur distribution function, which is used in estimating noise levels.
#'
#' @param x0 A numeric value representing the lower limit of integration.
#' @param beta A numeric value indicating the ratio of columns to rows in the data matrix.
#' @param gamma A numeric value specifying the power to which the function should be raised during integration.
#'
#' @return A numeric value of the integrated Marčenko-Pastur function.
#'
#'#' @export
#'
incMarPas <- function(x0, beta, gamma) {
  topSpec <- (1 + sqrt(beta))^2
  botSpec <- (1 - sqrt(beta))^2

  MarPas <- function(x) {
    ifelse((topSpec - x) * (x - botSpec) > 0,
           sqrt(pmax((topSpec - x) * (x - botSpec), 0)) / (beta * x) / (2 * pi),
           0)
  }


  if (gamma != 0) {
    fun <- function(x) x^gamma * MarPas(x)
  } else {
    fun <- MarPas
  }

  I <- integrate(fun, x0, topSpec)$value
  return(I)
}
