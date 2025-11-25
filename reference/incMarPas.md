# Incomplete Marčenko-Pastur Distribution Function

Computes the incomplete Marčenko-Pastur distribution function, which is
used in estimating noise levels.

## Usage

``` r
incMarPas(x0, beta, gamma)
```

## Arguments

- x0:

  A numeric value representing the lower limit of integration.

- beta:

  A numeric value indicating the ratio of columns to rows in the data
  matrix.

- gamma:

  A numeric value specifying the power to which the function should be
  raised during integration.

## Value

A numeric value of the integrated Marčenko-Pastur function.
