#' Extract Top Contributing Features for a DIVAS Component
#'
#' Identifies the most important features contributing to a specified component
#' within a given modality by ranking features based on their loading values.
#'
#' @param divasRes A DIVAS result object containing a \code{Loadings} element.
#' @param compName Character string specifying the component name.
#' @param modName Character string specifying the modality name.
#' @param n_top_pos Integer specifying the number of top positive features to return.
#'   Default is 100.
#' @param n_top_neg Integer specifying the number of top negative features to return.
#'   Default is 100.
#' @param return_values Logical indicating whether to return loading values along with
#'   feature names. Default is FALSE.
#'
#' @return If \code{return_values = FALSE}, returns a list with two elements:
#'   \itemize{
#'     \item \code{top_positive}: Character vector of feature names with highest positive loadings
#'     \item \code{top_negative}: Character vector of feature names with highest negative loadings (most negative)
#'   }
#'   If \code{return_values = TRUE}, returns a list with two elements:
#'   \itemize{
#'     \item \code{top_positive}: Named numeric vector of top positive loadings
#'     \item \code{top_negative}: Named numeric vector of top negative loadings
#'   }
#'
#' @details
#' Features are ranked by their loading values for the specified component.
#' Positive loadings indicate features that vary in the same direction as the component,
#' while negative loadings indicate features that vary in the opposite direction.
#' The function allows asymmetric selection of top positive and negative features,
#' which can be useful when one direction is of greater biological interest.
#'
#' @examples
#' \dontrun{
#' # Get top 100 positive and 100 negative features
#' top_features <- getTopFeatures(
#'   divasRes = divasRes,
#'   compName = "CD4_T_combined+CD8_T_combined+CD14_Monocyte+NK+proteomics+metabolomics-1",
#'   modName = "CD4_T_combined"
#' )
#'
#' # Get top 50 positive and 200 negative features with loading values
#' top_features_values <- getTopFeatures(
#'   divasRes = divasRes,
#'   compName = "CD4_T_combined+CD8_T_combined+CD14_Monocyte+NK+proteomics+metabolomics-1",
#'   modName = "CD4_T_combined",
#'   n_top_pos = 50,
#'   n_top_neg = 200,
#'   return_values = TRUE
#' )
#'
#' # Access results
#' pos_features <- top_features$top_positive
#' neg_features <- top_features$top_negative
#' }
#'
#' @export
getTopFeatures <- function(divasRes,
                           compName,
                           modName,
                           n_top_pos = 100,
                           n_top_neg = 100,
                           return_values = FALSE) {
  
  # Input validation
  if (!is.list(divasRes) || !"Loadings" %in% names(divasRes)) {
    stop("divasRes must be a DIVAS result object containing a 'Loadings' element")
  }
  
  if (!modName %in% names(divasRes$Loadings)) {
    stop(sprintf("Modality '%s' not found in DIVAS results. Available modalities: %s",
                 modName, paste(names(divasRes$Loadings), collapse = ", ")))
  }
  
  if (!compName %in% colnames(divasRes$Loadings[[modName]])) {
    stop(sprintf("Component '%s' not found in modality '%s'. Available components: %s",
                 compName, modName, paste(colnames(divasRes$Loadings[[modName]]), collapse = ", ")))
  }
  
  if (!is.numeric(n_top_pos) || n_top_pos < 1 || n_top_pos != as.integer(n_top_pos)) {
    stop("n_top_pos must be a positive integer")
  }
  
  if (!is.numeric(n_top_neg) || n_top_neg < 1 || n_top_neg != as.integer(n_top_neg)) {
    stop("n_top_neg must be a positive integer")
  }
  
  # Extract loadings for specified component
  ld <- divasRes$Loadings[[modName]][, compName]
  n_features <- length(ld)
  
  # Check if requested number of features exceeds available features
  if (n_top_pos > n_features) {
    warning(sprintf("n_top_pos (%d) exceeds total number of features (%d). Returning all features.",
                    n_top_pos, n_features))
    n_top_pos <- n_features
  }
  
  if (n_top_neg > n_features) {
    warning(sprintf("n_top_neg (%d) exceeds total number of features (%d). Returning all features.",
                    n_top_neg, n_features))
    n_top_neg <- n_features
  }
  
  # Sort loadings
  sortVec <- sort(ld)
  
  # Extract top negative features (most negative loadings)
  top_neg <- sortVec[1:n_top_neg]
  
  # Extract top positive features (most positive loadings)
  top_pos <- sortVec[n_features:(n_features - n_top_pos + 1)]
  
  # Return results
  if (return_values) {
    return(list(
      top_positive = top_pos,
      top_negative = top_neg
    ))
  } else {
    return(list(
      top_positive = names(top_pos),
      top_negative = names(top_neg)
    ))
  }
}

