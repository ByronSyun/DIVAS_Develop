PercentileMarcenkoPastur <- function(beta, perc) {
  nonzeroArea <- 1
  if (beta >= 1) {
    nonzeroArea <- 1 / beta
    perc <- perc * nonzeroArea
  }
  
  MarPas <- function(x) nonzeroArea - incMarPas(x, beta, 0)
  
  lobnd <- (1 - sqrt(beta))^2
  hibnd <- (1 + sqrt(beta))^2
  change <- TRUE
  
  while (change && (hibnd - lobnd > 0.001)) {
    change <- FALSE
    x <- seq(lobnd, hibnd, length.out = 5)
    y <- sapply(x, MarPas)
    
    if (any(y < perc)) {
      lobnd <- max(x[y < perc])
      change <- TRUE
    }
    
    if (any(y > perc)) {
      hibnd <- min(x[y > perc])
      change <- TRUE
    }
  }
  
  out <- (hibnd + lobnd) / 2
  return(out)
}

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


# # Test script for PercentileMarcenkoPastur.R
# 
# beta <- 0.5 
# perc <- 0.9  
# 
# 
# result <- PercentileMarcenkoPastur(beta, perc)
# 
# # Display the result
# cat("Test for PercentileMarcenkoPastur in R\n")
# cat("Beta:", beta, "\n")
# cat("Percentile:", perc, "\n")
# cat("Result:", result, "\n")

