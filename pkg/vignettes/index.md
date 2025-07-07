# DIVAS: Data Integration via Analysis of Subspaces

DIVAS (Data Integration via Analysis of Subspaces) is an R package for multi-modal data integration. Based on the DIVAS methodology proposed by Prothero et al. (2024), it provides tools for signal extraction, noise estimation, and joint structure identification from high-dimensional datasets, useful for multi-omics and other complex data types.

## Key Features

- **Multi-modal data integration** across different datasets
- **Identification of joint structure** across data blocks
- **Signal extraction and noise filtering**
- **Visualization of shared patterns** across different datasets

## Available Datasets

| Dataset | Description | Size | Format | Reference |
|---------|-------------|------|--------|-----------|
| toyDataThreeWay.mat | Synthetic data with 3 blocks having known joint structures | 100×50, 100×40, 100×30 | .mat | Prothero et al. (2024) |
| gnp_imputed.qs | GNP economic time series data | 296×14 | .qs | Stock & Watson (2016) |
| covid_multi_omics.qs | Multi-omics COVID-19 patient data (plasma proteins, metabolites, PBMC transcriptomics) | 139 patients, 265 samples | .qs | Su et al. (2020) |

## Getting Started

To get started with DIVAS, check out the following guides:

- [Getting Started with DIVAS](getting_started.html) - Learn the basics of DIVAS through a tutorial with a toy dataset
- [DIVAS User Guide](DIVAS_User_Guide.html) - Comprehensive documentation of the DIVAS analysis process
- [DIVAS Application Example: GNP Economic Data](application_example.html) - A real-world example using economic data

## Installation

```R
# Install dependencies
install.packages("devtools")
devtools::install_version("CVXR", version = "0.99-7", repos = "http://cran.us.r-project.org")

# Install DIVAS from GitHub
devtools::install_github("ByronSyun/DIVAS_Develop/pkg", ref = "DIVAS-v1")
```

## Developers

- **[Jiadong Mao](https://github.com/jdongmao)** - Lead Developer, Maintainer
- **[Yinuo Sun](https://github.com/ByronSyun)** - Package Maintainer

## References

Prothero, J., et al. (2024). Data integration via analysis of subspaces (DIVAS). 

Su, Y., Chen, D., Yuan, D., et al. (2020). Multi-Omics Resolves a Sharp Disease-State Shift between Mild and Moderate COVID-19. Cell, 183(6), 1479-1495. https://doi.org/10.1016/j.cell.2020.10.037 