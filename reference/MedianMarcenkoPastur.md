# Calculate the Median of the Marčenko-Pastur Distribution

This function estimates the median of the Marčenko-Pastur distribution
given a ratio parameter `beta`. The Marčenko-Pastur distribution
describes the asymptotic behavior of eigenvalues of large random
matrices and is widely used in random matrix theory and statistics for
noise estimation and signal processing.

## Usage

``` r
MedianMarcenkoPastur(beta)
```

## Arguments

- beta:

  A numeric value between 0 and 1 representing the aspect ratio of the
  matrix (`n/d`), where `n` is the number of columns and `d` is the
  number of rows. This ratio defines the shape of the Marčenko-Pastur
  distribution.

## Value

A numeric value representing the estimated median of the Marčenko-Pastur
distribution.

## Details

The function iteratively narrows down the interval containing the median
of the Marčenko-Pastur distribution by evaluating the distribution
function until the interval is sufficiently small. The bounds of the
distribution are defined by `(1 - sqrt(beta))^2` and
`(1 + sqrt(beta))^2`.
