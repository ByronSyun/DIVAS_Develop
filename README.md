# DIVAS

## Introduction

DIVAS (Data Integration via Analysis of Subspaces) is an R package for multi-modal data integration. Based on the DIVAS methodology proposed by Prothero et al. (2024), it provides tools for signal extraction, noise estimation, and joint structure identification from high-dimensional datasets, useful for multi-omics and other complex data types.

## Installation

### Dependencies

DIVAS package requires a specific version of CVXR (0.99-7). Please install the correct version of CVXR first:

```R
# Install devtools (if not already installed)
install.packages("devtools")

# Install the specified version of CVXR
devtools::install_version("CVXR", version = "0.99-7", repos = "http://cran.us.r-project.org")
```

### Installing the DIVAS package

```R
# Install DIVAS package from GitHub
devtools::install_github("ByronSyun/DIVAS_Develop", ref = "DIVAS-v1")

# Or install from local folder
devtools::install("path/to/DIVAS")
```

## Usage Examples

The DIVAS package supports analysis of various data formats. Here are two examples using different data formats:

### Example 1: Using MATLAB data

```R
# Load necessary libraries
library(devtools)
library(R.matlab)
library(DIVAS)

# Read MATLAB data
data <- readMat('toyDataThreeWay.mat')

# Prepare data blocks
datablock <- list(
  X1 = data$datablock[1,1][[1]][[1]],
  X2 = data$datablock[1,2][[1]][[1]],
  X3 = data$datablock[1,3][[1]][[1]]
)

# Run DIVAS main function
result <- DIVASmain(datablock)

# Visualize results
dataname <- paste0("DataBlock_", 1:length(datablock))
plots <- DJIVEAngleDiagnosticJP(datablock, dataname, result, 566, "Demo")
print(plots)
```

### Example 2: Using qs data format

```R
# Load necessary libraries
library(devtools)
library(qs)
library(DIVAS)

# Read qs format data
gnp <- qread("gnp_imputed.qs")
datablock <- gnp$datablock

# Run DIVAS main function (with parameters)
divasRes <- DIVASmain(datablock, nsim = 400, colCent = TRUE)

# Visualize results
dataname <- paste0("DataBlock_", 1:length(datablock))
plots <- DJIVEAngleDiagnosticJP(datablock, dataname, divasRes, 566, "Demo")
print(plots)
```

## Main Functions

### DIVASmain

The main function for executing DIVAS algorithm analysis.

**Parameters:**
- `datablock`: List of data blocks, each element representing a dataset
- `nsim`: Number of simulations, default 400
- `colCent`: Whether to perform column centering, default TRUE

**Returns:**
A list containing analysis results, which can be used for subsequent visualization and analysis.

### DJIVEAngleDiagnosticJP

Used to visualize DIVAS analysis results.

**Parameters:**
- `datablock`: Original data blocks
- `dataname`: Vector of data block names
- `outstruct`: Output result from DIVASmain
- `randseed`: Random seed
- `titlestr`: Chart title

**Returns:**
List of ggplot objects, including rank, score, and loading plots.

## References

Prothero et al. (2024). Data integration via analysis of subspaces (DIVAS).

