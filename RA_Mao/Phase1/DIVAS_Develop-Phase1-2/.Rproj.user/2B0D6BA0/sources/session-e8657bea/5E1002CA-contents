#' Convert Logical Index Array to Number (Binary to Decimal)
#'
#' This function takes a logical vector and converts it to a decimal number,
#' interpreting the logical values as a binary representation.
#'
#' @param blockIn A logical vector indicating which block index is in (TRUE/FALSE).
#' @return A numeric value representing the decimal conversion of the binary input.
#' @export
Idx2numMJ <- function(blockIn) {
  # Ensure input is a logical vector
  if (!is.logical(blockIn)) {
    stop("Input must be a logical vector.")
  }

  nb <- length(blockIn)
  t <- 0
  for (i in 1:nb) {
    if (blockIn[i]) {
      t <- t + 2^(i - 1)
    }
  }
  return(t)
}
