# Signal Matrix Extraction for DIVAS

Extracts the signal matrix for each data block, estimates signal ranks,
and adjusts perturbation angles for each data matrix.

## Usage

``` r
DJIVESignalExtractJP(
  datablock,
  nsim = 400,
  iplot = FALSE,
  colCent = F,
  rowCent = F,
  cull = 0.382,
  noisepercentile = rep(0.5, length(datablock)),
  noiselvls = NULL,
  seed = NULL
)
```

## Arguments

- datablock:

  A list of feature by sample (eg gene by cell) data matrices, each
  matrix corresponding to a data block. Matrices have to have same
  number of columns (mathced samples).

- nsim:

  An integer specifying the number of bootstrap samples.

- iplot:

  A logical to indicate whether plots should be generated for
  visualizing singular value shrinkage.

- colCent:

  A logical indicating whether columns should be centered.

- rowCent:

  A logical indicating whether rows should be centered.

- cull:

  A numeric value for the culling parameter to adjust signal rank.

- noisepercentile:

  A numeric vector specifying the percentiles used for noise estimation
  for each data block.

- noiselvls:

  A list specifying noise levels for each data block; if NULL, noise
  levels are estimated internally.

- seed:

  Optional. An integer to set the seed for the random number generator.
  Default is \`NULL\`.

## Value

A list containing:

- VBars:

  List of adjusted signal row spaces for each data block.

- UBars:

  List of adjusted signal column spaces for each data block.

- phiBars:

  Vector of adjusted perturbation angles for each data matrix.

- psiBars:

  Vector of loadings perturbation angles for each data matrix.

- rBars:

  Vector of adjusted signal ranks for each data block.

- EHats:

  List of estimated noise matrices for each data block.

- singVals:

  List of singular values before shrinkage for each data block.

- singValsHat:

  List of singular values after shrinkage for each data block.

- rSteps:

  List of signal rank adjustment steps for each data block.

- VVHatCacheBars:

  List of cached VVHat matrices for bootstrap samples.

- UUHatCacheBars:

  List of cached UUHat matrices for bootstrap samples.
