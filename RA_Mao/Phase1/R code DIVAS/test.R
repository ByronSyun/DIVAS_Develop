if (!require("R.matlab")) {
  install.packages("R.matlab")
}
if (!require("RSpectra")) {
  install.packages("RSpectra")
}
library(RSpectra)
library(R.matlab)

source("/Users/byronsun/Desktop/RA_Mao/Phase1/R code DIVAS/PercentileMarcenkoPastur.R")
source("/Users/byronsun/Desktop/RA_Mao/Phase1/R code DIVAS/ksOpt.R")
source("/Users/byronsun/Desktop/RA_Mao/Phase1/R code DIVAS/randDirAngleMJ.R")
source("/Users/byronsun/Desktop/RA_Mao/Phase1/R code DIVAS/optimal_shrinkage.R")
source("/Users/byronsun/Desktop/RA_Mao/Phase1/R code DIVAS/MatSignalExtractJP.R")
source("/Users/byronsun/Desktop/RA_Mao/Phase1/R code DIVAS/DJIVESignalExtractJP.R")





source("/Users/byronsun/Desktop/R code DIVAS/Functions/DJIVESignalExtractMJ.R")
source("/Users/byronsun/Desktop/RA_Mao/R code DIVAS/optimal_shrinkage.R")

data <- readMat("/Users/byronsun/Desktop/R code DIVAS/Data/toyDataThreeWay.mat")

# nested list
datablock <- lapply(data$datablock, function(x) x[[1]])
dataname <- unlist(lapply(data$dataname, function(x) x[[1]]))
nsim <- 100  # number of bootstrap samples

result <- DJIVESignalExtractMJ(datablock, dataname, nsim)
str(result)


# Example for optimal_shrinkage.R:
singvals <- svd(matrix(rnorm(100), 10, 10))$d
beta <- 10 / 10  # row/col number ratio
result <- optimal_shrinkage(singvals, beta, loss = 'op', percentile = 0.5)
print(result$singvals)  # Shrinked
print(result$noiselvl)
