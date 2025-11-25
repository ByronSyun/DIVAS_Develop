# Data integration via analysis of subspaces

Main function for DIVAS analysis. Given a list of data blocks with
matched columns (samples), will return identified joint structure with
diagnostic plots.

## Usage

``` r
DIVASmain(
  datablock,
  nsim = 400,
  iprint = TRUE,
  colCent = FALSE,
  rowCent = FALSE,
  figdir = NULL,
  seed = NULL,
  ReturnDetail = FALSE
)
```

## Arguments

- datablock:

  A list of matrices with the same number of columns (samples).

- nsim:

  Number of bootstrap resamples for inferring angle bounds.

- iprint:

  Whether to print diagnostic figures.

- colCent:

  Whether to column centre the input data blocks.

- rowCent:

  Whether to row centre the input data blocks.

- figdir:

  If not NULL, then diagnostic plots will be saved to this directory.

- seed:

  Optional. An integer to set the seed for the random number generator
  to ensure reproducibility of the bootstrap analysis. Default is
  \`NULL\`.

- ReturnDetail:

  Logical. If FALSE (default), return a compact result list focusing on
  the most user-relevant elements to save storage space. If TRUE, return
  the full detailed result structure.

## Value

A list containing DIVAS integration results. Most important ones include

- matBlocks:

  List of scores representing shared and partially shared joint
  structures.

- matLoadings:

  List of loadings linking features in each data block with scores.

- keyIdxMap:

  Mapping between indices of the previous lists and data blocks.

- Scores:

  A comprehensive matrix with samples as rows and all component scores
  as columns. Column names follow the pattern "X-Way-Y" for joint
  structures (e.g., "6-Way-1", "5-Way-2") and "BlockName-Individual-Y"
  for individual structures. (Renamed from sampleScoreMatrix for
  clarity)

- scoresList:

  List of recalculated scores computed as X^T \* Loadings for each data
  block, offering an alternative to the original scores. (Renamed from
  Scores for clarity)

- Loadings:

  List of inverse loadings matrices for each data block. Each element is
  a features × components matrix, where rows are features and columns
  are components (e.g., "RNA+PRO+MIC-1", "RNA-1", etc.). Provides better
  biological interpretability than original matLoadings.

- LoadingsNames:

  A list of character vectors per data block, each listing available
  component names in Loadings\[\[block\]\].

See Details for more explanations.

## Details

DIVASmain returns a list containing all important information returned
from the DIVAS algorithm. For users, the most important ones are scores
(matBlocks), loadings (matLoadings) and an index book (keyIdxMap)
explaining what joint structures each score or loading matrix correpsond
to.

matBlocks is a list containing scores. Each element of matBlocks is
indexed by a number. For example, suppose one of the indices is "7",
then keyIdxMap\[\["7"\]\] contains indices of data blocks corresponding
to the index 7. That is, matBlocks\[\["7"\]\] contains the scores for
all samples representing the joint structures of data blocks in
keyIdxMap\[\["7"\]\].

## References

Prothero, J., Jiang, M., Hannig, J., Tran-Dinh, Q., Ackerman, A. and
Marron, J. S. (2024). Data integration via analysis of subspaces
(DIVAS). Test.
