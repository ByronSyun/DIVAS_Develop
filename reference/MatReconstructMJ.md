# MatReconstructMJ - Reconstruct joint block matrices and their loadings from data

MatReconstructMJ - Reconstruct joint block matrices and their loadings
from data

## Usage

``` r
MatReconstructMJ(X, matJointV, matJointOrder, matJointRanks)
```

## Arguments

- X:

  d x n data matrix

- matJointV:

  n x sum(r_t) joint structure basis matrix

- matJointOrder:

  List that keeps the order of joint blocks in matJointV

- matJointRanks:

  Vector containing the rank of each joint block in matJointV

## Value

A list containing \`matBlockMap\` (joint block matrix map) and
\`matLoadingMap\` (joint block loading map)
