# DIVAS: Data Integration via Analysis of Subspaces

<p align="center">
<img src="man/figures/DIVAS_logo.png" width="200" alt="DIVAS Logo">
</p>

## Introduction

DIVAS (Data Integration via Analysis of Subspaces) is an R package for multi-modal data integration. Based on the DIVAS methodology proposed by Prothero et al. (2024), it provides tools for signal extraction, noise estimation, and joint structure identification from high-dimensional datasets, useful for multi-omics and other complex data types.

**Documentation website**: [https://github.com/ByronSyun/DIVAS_Develop/tree/main](https://github.com/ByronSyun/DIVAS_Develop/tree/main)

## Repository Structure

```
DIVAS-main/              # Main project directory
├── pkg/                 # R package source code
├── docs/                # Generated documentation website
├── figs/                # Figures and logo files
├── papers/              # Related publications
└── sourceCode/          # Development code and examples
    ├── examples/        # Example R scripts
    └── matlab/          # Original MATLAB implementation
```

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
devtools::install_github("ByronSyun/DIVAS_Develop/pkg", ref = "DIVAS-v1")

# Or install from local folder
devtools::install("path/to/DIVAS/pkg")
```

## Usage Examples

The DIVAS package supports analysis of various data formats. Here are two examples using different data formats:

### Example 1: Using MATLAB data

```R
# Load necessary libraries
library(devtools)
library(R.matlab)
library(DIVAS)

# Construct the path to the data file within the package
data_path <- system.file("extdata", "toyDataThreeWay.mat", package = "DIVAS")
# Read MATLAB data
data <- readMat(data_path)

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

See the documentation website for more detailed examples and tutorials.

## Available Datasets

| Dataset             | Brief Description                                  | Vignette Link                                                                          | Format | Primary Reference      |
|---------------------|----------------------------------------------------|----------------------------------------------------------------------------------------|--------|------------------------|
| toyDataThreeWay.mat | Synthetic 3-block data with known joint structures | [Toy Dataset Example](articles/DIVAS_Toy_Dataset_Example.html)                           | .mat   | Prothero et al. (2024) |
| gnp_imputed.qs      | Multi-omics GNP data (RNA, Protein, MicroRNA)      | [GNP Dataset Example](articles/DIVAS_GNP_Dataset_Example.html)                           | .qs    | Klein et al. (2025)    |
| covid_multi_omics.qs | Multi-omics COVID-19 patient data (plasma proteins, metabolites, PBMC transcriptomics) | Coming Soon | .qs | Su et al. (2020) |

## Case Study: COVID-19 Multi-Omics Analysis

This project serves as a comprehensive, real-world application of the DIVAS package on a complex multi-omics dataset from a COVID-19 patient cohort. It demonstrates the full data processing and analysis workflow, from raw data cleaning to final DIVAS results, showcasing the practical utility of the package.

**➡️ [View the full analysis on GitHub](https://github.com/ByronSyun/DIVAS_COVID19_Analysis)**

## Developers

### Core Team

* **[Jiadong Mao](https://github.com/jiadongm)** - *Lead Developer, Maintainer*
* **[Yinuo Sun](https://github.com/ByronSyun)** - *Package Developer, Maintainer*

### Contributors

* **Kim-Anh Lê Cao** - *Author*
* **Geraldine Kong** - *Author*
* **xx** - *Author*

## References

Prothero, J., et al. (2024). Data integration via analysis of subspaces (DIVAS).

Su, Y., Chen, D., Yuan, D., et al. (2020). Multi-Omics Resolves a Sharp Disease-State Shift between Mild and Moderate COVID-19. Cell, 183(6), 1479-1495. https://doi.org/10.1016/j.cell.2020.10.037

## Contributing

We welcome contributions to the DIVAS package. Please see our [contributing guidelines](https://byronsyun.github.io/DIVAS_Develop/articles/contributing.html) for more information.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

