# Optimal Shrinkage of Singular Values

The \`optimal_shrinkage\` function performs optimal shrinkage of
singular values based on the specified loss function and estimated noise
level. The function supports three types of loss functions: Frobenius
("fro"), operator norm ("op"), and nuclear norm ("nuc").

## Usage

``` r
optimal_shrinkage(singvals, beta, loss, percentile, sigma)
```

## Arguments

- singvals:

  A numeric vector of singular values to be shrunk.

- beta:

  A numeric value representing the ratio of dimensions (min(n, d) /
  max(n, d)), where n and d are the dimensions of the matrix.

- loss:

  A string specifying the loss function to be used for shrinkage.
  Options are "fro" (Frobenius norm), "op" (operator norm), and "nuc"
  (nuclear norm).

- percentile:

  A numeric value representing the percentile used for noise level
  estimation if \`sigma\` is not provided.

- sigma:

  Optional. A numeric value representing the noise level. If not
  provided, it will be estimated using the Median Marcenko-Pastur
  distribution.

## Value

A list containing:

- singvals:

  The shrunk singular values as a numeric vector.

- noiselvl:

  The estimated noise level used in the shrinkage process.
