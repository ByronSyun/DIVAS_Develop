# DJIVEReconstructMJ - Reconstruct joint blocks from data blocks

This function reconstructs joint blocks from the provided data matrices
using the estimated partially shared structures.

## Usage

``` r
DJIVEReconstructMJ(
  datablock,
  dataname,
  outMap,
  keyIdxMap,
  jointBlockOrder,
  doubleCenter
)
```

## Arguments

- datablock:

  List of d_k x n data matrices.

- dataname:

  Vector of data matrix names.

- outMap:

  List mapping between block index set and estimated partially shared
  structure.

- keyIdxMap:

  List mapping between joint block index and data blocks.

- jointBlockOrder:

  Vector to record the joint block order.

- doubleCenter:

  Flag indicating whether to perform double centering.

## Value

A list containing the joint basis map, loadings, and joint blocks.
