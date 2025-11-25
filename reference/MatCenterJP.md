# Center a Matrix by Rows, Columns, or Both

This function centers a matrix by subtracting the row means, column
means, or both, depending on the specified centering options. It is
useful in data preprocessing to normalize data for further analysis.

## Usage

``` r
MatCenterJP(X, iColCent = F, iRowCent = F)
```

## Arguments

- X:

  A numeric matrix to be centered.

- iColCent:

  A logical value indicating whether to center by columns. If \`TRUE\`,
  the function subtracts the row means from each column.

- iRowCent:

  A logical value indicating whether to center by rows. If \`TRUE\`, the
  function subtracts the column means from each row.

## Value

A centered matrix with the specified adjustments applied. If both
\`iColCent\` and \`iRowCent\` are \`TRUE\`, the matrix will be centered
by both rows and columns.
