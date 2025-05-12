# DIVAS: Data Integration via Analysis of Subspaces

<img src="../reference/figures/logo.png" align="right" width="150" />

## Overview

DIVAS is an R package for multi-modal data integration based on the methodology proposed by Prothero et al. (2024). It provides tools for signal extraction, noise estimation, and joint structure identification from high-dimensional datasets.

## Key Features

- **Signal Extraction**: Identify significant signals in each dataset while filtering out noise
- **Joint Structure Identification**: Find shared patterns across multiple datasets
- **Structure Reconstruction**: Reconstruct the original data based on the identified structures
- **Visualization**: Generate diagnostic plots to understand the identified structures

## Documentation

Explore our documentation to learn more about DIVAS:

- [**Getting Started**](articles/getting_started.html): Learn the basics of DIVAS
- [**User Guide**](articles/DIVAS_User_Guide.html): Comprehensive guide to the DIVAS analysis process
- [**Application Example**](articles/application_example.html): Example analysis of economic data
- [**Function Reference**](reference/index.html): Detailed documentation of all functions
- [**Contributing**](articles/contributing.html): Guidelines for contributing to the project

## Installation

```r
# Install devtools if needed
install.packages("devtools")

# Install DIVAS from GitHub
devtools::install_github("ByronSyun/DIVAS_Develop/pkg")
```

## Usage Example

```r
# Load libraries
library(DIVAS)
library(R.matlab)

# Load example data
data <- readMat(system.file("extdata", "toyDataThreeWay.mat", package = "DIVAS"))
datablock <- list(
  X1 = data$datablock[1,1][[1]][[1]],
  X2 = data$datablock[1,2][[1]][[1]],
  X3 = data$datablock[1,3][[1]][[1]]
)

# Run DIVAS analysis
result <- DIVASmain(datablock, nsim = 300)

# Create visualization
dataname <- paste0("DataBlock_", 1:length(datablock))
plots <- DJIVEAngleDiagnosticJP(datablock, dataname, result, 566, "Demo")
``` 