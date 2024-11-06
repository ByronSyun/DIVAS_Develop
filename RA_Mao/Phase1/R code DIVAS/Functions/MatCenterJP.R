MatCenterJP <- function(X, iColCent, iRowCent) {

  d <- nrow(X)
  n <- ncol(X)
  outMat <- X
  if (iColCent) {
    outMat <- outMat - matrix(rowMeans(outMat), nrow = d, ncol = n, byrow = FALSE)
  }
  if (iRowCent) {
    outMat <- outMat - matrix(colMeans(outMat), nrow = d, ncol = n, byrow = TRUE)
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
