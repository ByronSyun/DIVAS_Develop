# Calculate Random Direction Angles

Computes angles between random vectors and their projections onto first
r components

This function simulates the angles between a random direction and a
fixed rank \`r\` subspace in \\R^n\\. Specifically, it calculates the
angles between a random vector and the subspace spanned by the first
\`r\` dimensions in an \\n\\-dimensional space.

## Usage

``` r
randDirAngleMJ(n, r, nsim)

randDirAngleMJ(n, r, nsim)
```

## Arguments

- n:

  An integer representing the dimension of the vector space.

- r:

  An integer representing the dimension of the subspace.

- nsim:

  An integer representing the number of simulation samples.

## Value

Vector of angles in degrees

A numeric vector of length \`nsim\`, containing the simulated random
direction angles (in degrees).
