# Optimal Shrinkage of Singular Values

Performs optimal shrinkage of singular values according to a specified
loss function, given the shape parameter `beta` and noise level `sigma`.
This function adjusts the singular values of a matrix to reduce noise
and enhance signal components based on the Marčenko-Pastur distribution.

## Usage

``` r
optshrink_impl(singvals, beta, loss, sigma)
```

## Arguments

- singvals:

  A numeric vector of singular values to be shrunk.

- beta:

  A numeric value between 0 and 1 representing the aspect ratio of the
  matrix (`n/d`), where `n` is the number of columns and `d` is the
  number of rows.

- loss:

  A character string specifying the type of loss function to use for
  shrinkage. Must be one of `"fro"` (Frobenius norm), `"op"` (Operator
  norm), or `"nuc"` (Nuclear norm).

- sigma:

  A positive numeric value representing the noise level to be used in
  the shrinkage process.

## Value

A numeric vector of shrunk singular values.

## Details

The function applies different shrinkage strategies based on the
specified loss function:

- `"fro"`:

  Uses Frobenius norm shrinkage, which minimizes the mean squared error.

- `"op"`:

  Uses Operator norm shrinkage, which targets the largest singular
  value.

- `"nuc"`:

  Uses Nuclear norm shrinkage, which adjusts the sum of singular values
  while penalizing those close to zero.

Internal helper functions are used to compute the adjusted singular
values according to the specified loss type:

- `opt_fro_shrink`:

  Calculates shrinkage based on the Frobenius norm.

- `opt_op_shrink`:

  Calculates shrinkage based on the Operator norm.

- `opt_nuc_shrink`:

  Calculates shrinkage based on the Nuclear norm.
