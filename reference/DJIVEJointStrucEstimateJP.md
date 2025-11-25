# Estimate full and partially shared joint structures Establish a DC programming problem to estimate each partially joint structure using Penalty CCP algorithm.

Estimate full and partially shared joint structures Establish a DC
programming problem to estimate each partially joint structure using
Penalty CCP algorithm.

## Usage

``` r
DJIVEJointStrucEstimateJP(
  VBars,
  UBars,
  phiBars,
  psiBars,
  rBars,
  dataname = NULL,
  theta0 = 45,
  optArgin = list(),
  iprint = F,
  figdir = NULL
)
```

## Arguments

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

- dataname:

  Names of data blocks.

- theta0:

  Initial value for angle.

- optArgin:

  Aditional tuning parameters for optimisation.

- iprint:

  Print the figures or not.

- figdir:

  If not \`NULL\`, will be parsed as directory for storing the figures.

## Value

A list containing:

- outMap:

  Mapping between joint block index set and estimated partially shared
  structure.

- keyIdxMap:

  Mapping between joint block index and data blocks.

- anglesMap:

  Mapping between joint block index and angle estimates.

- jointBlockOrder:

  Record of the order of joint blocks.
