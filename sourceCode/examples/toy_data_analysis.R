# DIVAS - Toy Dataset Analysis Example
# This script demonstrates a complete analysis workflow using the DIVAS methodology
# on the toyDataThreeWay dataset provided with the package.

# Load required libraries
library(DIVAS)
library(R.matlab)
library(ggplot2)
library(gridExtra)

# Set random seed for reproducibility
set.seed(566)

# ----------------------------------------------------------
# 1. DATA LOADING AND PREPARATION
# ----------------------------------------------------------

# Load toy data (MATLAB format)
data_path <- system.file("extdata", "toyDataThreeWay.mat", package = "DIVAS")
# If the package isn't installed, use a local path:
# data_path <- "path/to/toyDataThreeWay.mat"
data <- readMat(data_path)

# Prepare data blocks
datablock <- list(
  X1 = data$datablock[1,1][[1]][[1]],
  X2 = data$datablock[1,2][[1]][[1]],
  X3 = data$datablock[1,3][[1]][[1]]
)

# Display basic information about each data block
cat("Data Block Dimensions:\n")
for (i in 1:length(datablock)) {
  cat(sprintf("X%d: %d x %d\n", i, nrow(datablock[[i]]), ncol(datablock[[i]])))
}

# ----------------------------------------------------------
# 2. DIVAS ANALYSIS
# ----------------------------------------------------------

# Run the main DIVAS analysis
cat("\nRunning DIVAS analysis...\n")
result <- DIVASmain(datablock, nsim = 300, colCent = TRUE)

# Print key results
cat("\nRank Estimation Results:\n")
print(result$estRank)

# ----------------------------------------------------------
# 3. VISUALIZATION
# ----------------------------------------------------------

# Create data block names for plotting
dataname <- paste0("DataBlock_", 1:length(datablock))

# Generate diagnostic plots
cat("\nGenerating diagnostic plots...\n")
plots <- DJIVEAngleDiagnosticJP(datablock, dataname, result, 566, "Toy Data Example")

# Display plots
if (interactive()) {
  print(plots$loadings)
  print(plots$scores)
}

# Save plots to file
# ggsave("divas_loadings.png", plots$loadings, width = 10, height = 7)
# ggsave("divas_scores.png", plots$scores, width = 10, height = 7)

# ----------------------------------------------------------
# 4. INTERPRETATION
# ----------------------------------------------------------

cat("\nInterpretation of Results:\n")
cat("1. Joint Structure: The analysis identified shared signal dimensions across data blocks.\n")
cat("2. Visualization: The loading and score plots show how variables and samples contribute to joint structures.\n")
cat("3. Results indicate that the toy dataset contains the following structures:\n")
cat("   - Structure shared across all three blocks: ", sum(result$estRank$rank[1,]), "\n")
cat("   - Structure shared between blocks 1-2: ", sum(result$estRank$rank[2,]), "\n")
cat("   - Structure shared between blocks 1-3: ", sum(result$estRank$rank[3,]), "\n")
cat("   - Structure shared between blocks 2-3: ", sum(result$estRank$rank[4,]), "\n")
cat("   - Structure unique to block 1: ", sum(result$estRank$rank[5,]), "\n")
cat("   - Structure unique to block 2: ", sum(result$estRank$rank[6,]), "\n")
cat("   - Structure unique to block 3: ", sum(result$estRank$rank[7,]), "\n")

# ----------------------------------------------------------
# 5. ADDITIONAL ANALYSES (OPTIONAL)
# ----------------------------------------------------------

# Reconstruct the data blocks
reconstructed <- DJIVEReconstructMJ(datablock, result$dimsdir)

# Calculate reconstruction accuracy
calc_rmse <- function(actual, predicted) {
  sqrt(mean((actual - predicted)^2))
}

cat("\nReconstruction RMSE:\n")
for (i in 1:length(datablock)) {
  rmse <- calc_rmse(datablock[[i]], reconstructed[[i]])
  cat(sprintf("Block %d: %.6f\n", i, rmse))
}

cat("\nAnalysis complete!\n") 