# Create Diagnostic Plots for DJIVE Analysis

Create Diagnostic Plots for DJIVE Analysis

## Usage

``` r
DJIVEAngleDiagnosticJP(datablock, dataname, outstruct, randseed, titlestr)
```

## Arguments

- datablock:

  List of data blocks

- dataname:

  Vector of data block names

- outstruct:

  Output structure from DJIVE analysis

- randseed:

  Random seed for reproducibility

- titlestr:

  Title string for plots

## Value

List of three ggplot objects: rank, score, and loading plots
