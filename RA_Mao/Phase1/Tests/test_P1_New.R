#install.packages("devtools")
library(devtools)
# Install DIVASpackage from GitHub
# install_github("ByronSyun/DIVAS_Develop", ref = "Phase1")
Sys.setenv(GITHUB_PAT = "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")
devtools::install_github("ByronSyun/DIVAS_Develop", ref = "Phase1")


library('DIVASpackage')
#install.packages("RSpectra")
#library(RSpectra)


library(R.matlab)
# datablock <- data$datablock
data <- readMat('~/Desktop/RA_Mao/Phase1/Tests/toyDataThreeWay.mat')

# datablocks from the list and convert to matrix
datablock <- lapply(data$datablock, function(x) x[[1]])
datablock <- matrix(list(datablock[[1]], datablock[[2]], datablock[[3]]), nrow = 1, ncol = 3)


dataname <- c('datablock1', 'datablock2', 'datablock3')
nsim <- 400
iplot <- 0
colCent <- 0
rowCent <- 0
cull <- 0.5
noisepercentile <- c(0.9, 0.85, 0.8) # not real

result <- DJIVESignalExtractJP(
  datablock = datablock,
  dataname = dataname,
  nsim = nsim,
  iplot = iplot,
  colCent = colCent,
  rowCent = rowCent,
  cull = cull,
  noisepercentile = noisepercentile
)


cat("Adjusted signal ranks (rBars):\n")
print(result$rBars)

cat("Perturbation angles (phiBars):\n")
print(result$phiBars)

cat("Loadings perturbation angles (psiBars):\n")
print(result$psiBars)


