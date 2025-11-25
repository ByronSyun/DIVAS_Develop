# Optimal Shrinkage Estimation using Kolmogorov-Smirnov Criterion

This function estimates the optimal shrinkage parameter for singular
values using the Kolmogorov-Smirnov (KS) criterion, which helps identify
noise levels in high-dimensional data.

## Usage

``` r
ksOpt(singVals, betaShrinkage)
```

## Arguments

- singVals:

  A numeric vector of singular values from a data matrix.

- betaShrinkage:

  A numeric value representing the aspect ratio of the data matrix
  (ratio of columns to rows or vice versa).

## Value

A numeric value representing the estimated optimal noise level (sigma)
based on the KS criterion.
