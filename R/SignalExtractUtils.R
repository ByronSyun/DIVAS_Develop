#' Arccosine in Degrees
#'
#' The `acosd` function computes the inverse cosine (arccosine) of a numeric value and converts the result from radians to degrees.
#'
#' @param x A numeric value or vector. The input should be within the range [-1, 1], as values outside this range will produce NaN values.
#'
#' @return A numeric value or vector representing the arccosine of the input, expressed in degrees.
#'
acosd <- function(x) {
  return(acos(x) * 180 / pi)
}



#' Center a Matrix by Rows, Columns, or Both
#'
#' This function centers a matrix by subtracting the row means, column means, or both, depending on the specified centering options. It is useful in data preprocessing to normalize data for further analysis.
#'
#' @param X A numeric matrix to be centered.
#' @param iColCent A logical value indicating whether to center by columns. If `TRUE`, the function subtracts the row means from each column.
#' @param iRowCent A logical value indicating whether to center by rows. If `TRUE`, the function subtracts the column means from each row.
#'
#' @return A centered matrix with the specified adjustments applied. If both `iColCent` and `iRowCent` are `TRUE`, the matrix will be centered by both rows and columns.
#' @export
#'
MatCenterJP <- function(X, iColCent = F, iRowCent = F) {

  d <- nrow(X)
  n <- ncol(X)
  outMat <- X
  if (iColCent) {
    outMat <- sweep(outMat, 1, rowMeans(outMat), "-")
  }
  if (iRowCent) {
    outMat <- sweep(outMat, 2, colMeans(outMat), "-")
  }
  return(outMat)
}
#
# ####################################test######################################
# # Sample data matrix
# X <- matrix(c(1, 2, 333, 4, 5, 6, 7, 8, 9), nrow = 3, ncol = 3, byrow = TRUE)
# print("Test matrix:")
# print(X)
#
# print("Centering by columns only:")
# print(MatCenterJP(X, iColCent = TRUE, iRowCent = FALSE))
#
# print("Centering by rows only:")
# print(MatCenterJP(X, iColCent = FALSE, iRowCent = TRUE))
#
# print("Centering by both rows and columns:")
# print(MatCenterJP(X, iColCent = TRUE, iRowCent = TRUE))
