# DIVAS MATLAB Implementation

This directory contains the original MATLAB implementation of the DIVAS methodology, based on the code from the repository: [Data-Integration-Via-Analysis-of-Subspaces](https://github.com/jbprothero/Data-Integration-Via-Analysis-of-Subspaces).

## Contents

- **DJIVECode/**: Core MATLAB functions for the DIVAS methodology
- **DemoScript.m**: Example script demonstrating the usage of DIVAS in MATLAB

## Requirements

To run this MATLAB implementation, you need:

1. MATLAB (tested on 2019b and newer)
2. CVX optimization package: [http://cvxr.com/cvx/](http://cvxr.com/cvx/)

## Usage

The main functionality is provided through the `DJIVEMainJP()` function, which takes data blocks as input and runs three main subroutines:

1. `DJIVESignalExtractJP()`: Extracts signal ranks and perturbation angles
2. `DJIVEJointStrucEstimateJPLoadInfo()`: Identifies shared structure between data blocks
3. `DJIVEReconstructMJ()`: Solves for loading structures corresponding to score structures

For visualization of results, use the `DJIVEAngleDiagnosticJP()` function.

## R Implementation

This MATLAB code served as the foundation for the R implementation of DIVAS provided in this package. The R version has been optimized and adapted to work within the R ecosystem while maintaining the core methodology.

## Citation

If you use this MATLAB implementation in your research, please cite:

Prothero, J., et al. (2024). Data integration via analysis of subspaces (DIVAS). 