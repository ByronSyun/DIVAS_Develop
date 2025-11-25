# Percentile of the Marcenko-Pastur Distribution

This function calculates a specified percentile of the Marcenko-Pastur
distribution, which is used in random matrix theory to model the
distribution of singular values of large random matrices. It adjusts the
percentile calculation based on the shape parameter \`beta\`.

## Usage

``` r
PercentileMarcenkoPastur(beta, perc)
```

## Arguments

- beta:

  A numeric value representing the shape parameter of the
  Marcenko-Pastur distribution. It should be between 0 and 1.

- perc:

  A numeric value between 0 and 1, representing the desired percentile
  of the Marcenko-Pastur distribution.

## Value

A numeric value representing the calculated percentile of the
Marcenko-Pastur distribution.
