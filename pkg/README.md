# DIVAS

## Overview

DIVAS (Data Integration via Analysis of Subspaces) is an R package for multi-modal data integration. It provides tools for signal extraction, noise estimation, and joint structure identification from high-dimensional datasets.

## Installation

### Dependencies

DIVAS package requires a specific version of CVXR (0.99-7):

```R
# Install devtools (if not already installed)
install.packages("devtools")

# Install the specific version of CVXR
devtools::install_version("CVXR", version = "0.99-7", repos = "http://cran.us.r-project.org")
```

### Installing DIVAS

```R
# Install DIVAS from GitHub
devtools::install_github("ByronSyun/DIVAS_Develop/pkg", ref = "DIVAS-v1")
```

## Basic Usage

```R
library(DIVAS)

# Load example data
# Result <- DIVASmain(datablock)
# See vignettes for detailed examples
```

## Documentation

For detailed documentation, see the package vignettes. 