# Extract Top Contributing Features for a DIVAS Component

Identifies the most important features contributing to a specified
component within a given modality by ranking features based on their
loading values.

## Usage

``` r
getTopFeatures(
  divasRes,
  compName,
  modName,
  n_top_pos = 100,
  n_top_neg = 100,
  return_values = FALSE
)
```

## Arguments

- divasRes:

  A DIVAS result object containing a `Loadings` element.

- compName:

  Character string specifying the component name.

- modName:

  Character string specifying the modality name.

- n_top_pos:

  Integer specifying the number of top positive features to return.
  Default is 100.

- n_top_neg:

  Integer specifying the number of top negative features to return.
  Default is 100.

- return_values:

  Logical indicating whether to return loading values along with feature
  names. Default is FALSE.

## Value

If `return_values = FALSE`, returns a list with two elements:

- `top_positive`: Character vector of feature names with highest
  positive loadings

- `top_negative`: Character vector of feature names with highest
  negative loadings (most negative)

If `return_values = TRUE`, returns a list with two elements:

- `top_positive`: Named numeric vector of top positive loadings

- `top_negative`: Named numeric vector of top negative loadings

## Details

Features are ranked by their loading values for the specified component.
Positive loadings indicate features that vary in the same direction as
the component, while negative loadings indicate features that vary in
the opposite direction. The function allows asymmetric selection of top
positive and negative features, which can be useful when one direction
is of greater biological interest.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get top 100 positive and 100 negative features
top_features <- getTopFeatures(
  divasRes = divasRes,
  compName = "CD4_T_combined+CD8_T_combined+CD14_Monocyte+NK+proteomics+metabolomics-1",
  modName = "CD4_T_combined"
)

# Get top 50 positive and 200 negative features with loading values
top_features_values <- getTopFeatures(
  divasRes = divasRes,
  compName = "CD4_T_combined+CD8_T_combined+CD14_Monocyte+NK+proteomics+metabolomics-1",
  modName = "CD4_T_combined",
  n_top_pos = 50,
  n_top_neg = 200,
  return_values = TRUE
)

# Access results
pos_features <- top_features$top_positive
neg_features <- top_features$top_negative
} # }
```
