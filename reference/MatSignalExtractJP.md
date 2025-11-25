# Matrix Signal Extraction

The \`MatSignalExtractJP\` function performs signal extraction from a
data matrix to estimate the signal rank, signal row space, corresponding
perturbation angles, and noise matrix. It adjusts the signals based on
random direction angles and uses bootstrap estimation to refine the
results.

## Usage

``` r
MatSignalExtractJP(
  X,
  matName = NULL,
  nsim = 400,
  colCent = F,
  rowCent = F,
  cull = 0.382,
  percentile = 0.5,
  noiselvl = NULL,
  seed = NULL
)
```

## Arguments

- X:

  A numeric matrix (d x n) containing the data to be analyzed. Must not
  contain any \`NA\` values.

- matName:

  A string representing the name of the matrix, used for logging
  purposes.

- nsim:

  An integer specifying the number of bootstrap samples to be used
  during the estimation process.

- colCent:

  A logical value indicating whether to center the columns of the
  matrix. Default is \`FALSE\`.

- rowCent:

  A logical value indicating whether to center the rows of the matrix.
  Default is \`FALSE\`.

- cull:

  A numeric value controlling the culling process during signal
  extraction. Default is \`0.5\`.

- percentile:

  A numeric value representing the percentile for estimating the noise
  level.

- noiselvl:

  Optional. A noise level parameter that can be either a numeric value
  or 'ks' to use the \`ksOpt\` function for noise level estimation. If
  not provided, an optimal shrinkage method will be used.

- seed:

  Optional. A seed for the random number generator to ensure
  reproducibility.

## Value

A list containing:

- VBar:

  Matrix representing the adjusted signal row space.

- UBar:

  Matrix representing the adjusted signal column space.

- phiBar:

  Numeric value of the adjusted perturbation angle.

- psiBar:

  Numeric value of the loadings perturbation angle.

- rBar:

  Integer representing the adjusted signal rank.

- EHat:

  Matrix representing the estimated noise.

- singVals:

  Vector of singular values before shrinkage.

- singValsHat:

  Vector of singular values after shrinkage.

- rSteps:

  List of steps used in signal rank adjustment.

- VVHatCacheBar:

  List of matrices from bootstrap validation steps.

- UUHatCacheBar:

  List of matrices from bootstrap validation steps.
