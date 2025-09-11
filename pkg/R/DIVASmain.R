#' Data integration via analysis of subspaces
#'
#' Main function for DIVAS analysis. Given a list of data blocks with matched columns (samples), will return identified joint
#' structure with diagnostic plots.
#'
#' @param datablock A list of matrices with the same number of columns (samples).
#' @param nsim Number of bootstrap resamples for inferring angle bounds.
#' @param iprint Whether to print diagnostic figures.
#' @param colCent Whether to column centre the input data blocks.
#' @param rowCent Whether to row centre the input data blocks.
#' @param figdir If not NULL, then diagnostic plots will be saved to this directory.
#' @param seed Optional. An integer to set the seed for the random number generator to ensure reproducibility of the bootstrap analysis. Default is `NULL`.
#' @param ReturnDetail Logical. If FALSE (default), return a compact result list focusing on the most user-relevant elements to save storage space. If TRUE, return the full detailed result structure.                
#'
#' @importFrom MASS ginv
#' @return A list containing DIVAS integration results. Most important ones include
#'   \describe{
#'     \item{matBlocks}{List of scores representing shared and partially shared joint structures.}
#'     \item{matLoadings}{List of loadings linking features in each data block with scores.}
#'     \item{keyIdxMap}{Mapping between indices of the previous lists and data blocks.}
#'     \item{sampleScoreMatrix}{A comprehensive matrix with samples as rows and all component scores as columns. Column names follow the pattern "X-Way-Y" for joint structures (e.g., "6-Way-1", "5-Way-2") and "BlockName-Individual-Y" for individual structures.}
#'     \item{Loadings}{List of inverse loadings (generalized inverse of matLoadings) for each data block, providing better biological interpretability.}
#'     \item{Scores}{List of recalculated scores computed as X^T * Loadings for each data block, offering an alternative to the original scores.}
#'     \item{LoadingsNames}{A list of character vectors per data block, each listing available component names in Loadings[[block]].}
#'     \item{names_vec}{Alias of LoadingsNames, per data block character vectors of component names (for convenience).}
#'   }
#'   See Details for more explanations.
#'
#' @details
#' DIVASmain returns a list containing all important information returned from the DIVAS algorithm.
#' For users, the most important ones are scores (matBlocks), loadings (matLoadings) and an index
#' book (keyIdxMap) explaining what joint structures each score or loading matrix correpsond to.
#'
#' matBlocks is a list containing scores. Each element of matBlocks is indexed by a number.
#' For example, suppose one of the indices is "7", then keyIdxMap[["7"]] contains indices of data blocks
#' corresponding to the index 7. That is, matBlocks[["7"]] contains the scores for all samples
#' representing the joint structures of data blocks in keyIdxMap[["7"]].
#'
#' @references
#' Prothero, J., Jiang, M., Hannig, J., Tran-Dinh, Q., Ackerman, A. and Marron, J. S. (2024).
#' Data integration via analysis of subspaces (DIVAS). Test.
#'
#'
#' @export
DIVASmain <- function(
    datablock, nsim = 400, iprint = TRUE, colCent = FALSE, rowCent = FALSE,
    figdir = NULL, seed = NULL, ReturnDetail = FALSE
  ){

  # Initialize parameters
  nb <- length(datablock)
  dataname <- names(datablock)
  if(is.null(dataname)){
    warning("Input datablock is unnamed, generic names for data blocks generated.")
    dataname <- paste0("Datablock", 1:nb)
  }

  if (any(sapply(datablock, function(i) {
    !is.matrix(i)
  }))) {
    stop("datablock must be a list of matrices")
  }

  n <- ncol(datablock[[1]]) # Get number of samples

  # ---- Extract sample IDs from column names ----
  # Assumes all data blocks have the same samples in the same order
  sample_ids <- colnames(datablock[[1]])

  # ---- process dataname ----
  if (is.null(dataname)) {
    dataname <- names(datablock)
    if (is.null(dataname)) {
      # Generate default names if still NULL
      dataname <- paste0("Block", 1:nb)
    }
  }

  # Some tuning parameters for algorithms
  theta0 <- 45
  optArgin <- list(0.5, 1000, 1.05, 50, 1e-3, 1e-3)
  filterPerc <- 1 - (2 / (1 + sqrt(5))) # "Golden Ratio"
  noisepercentile <- rep(0.5, nb)


  rowSpaces <- vector("list", nb)
  # datablockc <- vector("list", nb)
  for (ib in seq_len(nb)) {
    rowSpaces[[ib]] <- 0
    datablock[[ib]] <- MatCenterJP(datablock[[ib]], colCent, rowCent)
  }

  # Step 1: Estimate signal space and perturbation angle
  Phase1 <- DJIVESignalExtractJP(
    datablock = datablock, nsim = nsim,
    iplot = FALSE, colCent = colCent, rowCent = rowCent, cull = filterPerc, noisepercentile = noisepercentile,
    seed = seed
  )
  # VBars <- Phase1[[1]]
  # UBars <- Phase1[[2]]
  # phiBars <- Phase1[[3]]
  # psiBars <- Phase1[[4]]
  # rBars <- Phase1[[6]]
  # VVHatCacheBars <- Phase1[[10]]
  # UUHatCacheBars <- Phase1[[11]]


  # Step 2: Estimate joint and partially joint structure
  Phase2 <- DJIVEJointStrucEstimateJP(
    VBars = Phase1$VBars, UBars = Phase1$UBars, phiBars =  Phase1$phiBars, psiBars =  Phase1$psiBars,
    rBars = Phase1$rBars, dataname = dataname, iprint = iprint, figdir = figdir
  )

  # outMap <- Phase2[[1]]
  # keyIdxMap <- Phase2[[2]]
  # jointBlockOrder <- Phase2[[4]]

  # Step 3: Reconstruct DJIVE decomposition
  outstruct <- DJIVEReconstructMJ(
    datablock = datablock, dataname =  dataname, outMap =  Phase2$outMap,
    keyIdxMap =  Phase2$keyIdxMap, jointBlockOrder =  Phase2$jointBlockOrder, doubleCenter =  0
  )

  outstruct$rBars <- Phase1$rBars
  outstruct$phiBars <- Phase1$phiBars
  outstruct$psiBars <- Phase1$psiBars
  outstruct$VBars <- Phase1$VBars
  outstruct$UBars <- Phase1$UBars
  outstruct$VVHatCacheBars <- Phase1$VVHatCacheBars
  outstruct$UUHatCacheBars <- Phase1$UUHatCacheBars
  outstruct$jointBasisMapRaw <- Phase2$outMap

  # Automatically generate keymapname from keymapid
  ids <- as.integer(names(outstruct$keyIdxMap))
  num_blocks <- length(dataname)
  
  keymapname <- sapply(ids, function(id) {
    binary_str <- R.utils::intToBin(id)
    padded_binary_str <- sprintf(paste0("%0", num_blocks, "s"), binary_str)
    binary_chars <- strsplit(padded_binary_str, "")[[1]]
    selected_indices <- which(rev(binary_chars) == '1')
    selected_names <- dataname[selected_indices]
    paste(selected_names, collapse = "+")
  })
  
  names(keymapname) <- names(outstruct$keyIdxMap)
  outstruct$keymapname <- keymapname

  # ---- Attach sample IDs to results ----
  if (!is.null(sample_ids)) {
    if (iprint) {
      cat("Attaching sample IDs to score matrices (jointBasisMap and indivBasisMap)...\\n")
    }
    # For joint structures
    if (length(outstruct$jointBasisMap) > 0) {
      outstruct$jointBasisMap <- lapply(outstruct$jointBasisMap, function(mat) {
        if (!is.null(mat)) rownames(mat) <- sample_ids
        return(mat)
      })
    }
    # For individual structures
    if (length(outstruct$indivBasisMap) > 0) {
      outstruct$indivBasisMap <- lapply(outstruct$indivBasisMap, function(mat) {
        if (!is.null(mat)) rownames(mat) <- sample_ids
        return(mat)
      })
    }
  }

  # ---- Create comprehensive sample-score matrix ----
  if (iprint) {
    cat("Creating comprehensive sample-score matrix...\\n")
  }
  
  # Initialize list to store all score columns
  score_columns <- list()
  column_names <- c()
  
  # Process joint structures (sorted by number of blocks, descending)
  if (length(outstruct$jointBasisMap) > 0) {
    # Get joint structure information
    joint_info <- data.frame(
      id = names(outstruct$jointBasisMap),
      stringsAsFactors = FALSE
    )
    
    # Calculate number of blocks for each joint structure
    joint_info$num_blocks <- sapply(joint_info$id, function(id) {
      length(outstruct$keyIdxMap[[id]])
    })
    
    # Sort by number of blocks (descending) then by id
    joint_info <- joint_info[order(-joint_info$num_blocks, joint_info$id), ]
    
    # Process each joint structure
    for (i in 1:nrow(joint_info)) {
      id <- joint_info$id[i]
      num_blocks <- joint_info$num_blocks[i]
      mat <- outstruct$jointBasisMap[[id]]
      
      if (!is.null(mat) && ncol(mat) > 0) {
        # Determine if this is a true joint structure (>1 block) or individual structure
        if (num_blocks > 1) {
          # True joint structure: use actual block names like "RNA+PRO+MIC-1", "RNA+PRO-1", etc.
          block_indices <- outstruct$keyIdxMap[[id]]
          block_names <- dataname[block_indices]
          joint_name <- paste(block_names, collapse = "+")
          
          for (rank_idx in 1:ncol(mat)) {
            col_name <- paste0(joint_name, "-", rank_idx)
            column_names <- c(column_names, col_name)
            score_columns[[col_name]] <- mat[, rank_idx]
          }
        } else {
          # Individual structure stored in jointBasisMap: "RNA-Individual-1", etc.
          block_idx <- outstruct$keyIdxMap[[id]][1]
          block_name <- dataname[block_idx]
          
          for (rank_idx in 1:ncol(mat)) {
            col_name <- paste0(block_name, "-Individual-", rank_idx)
            column_names <- c(column_names, col_name)
            score_columns[[col_name]] <- mat[, rank_idx]
          }
        }
      }
    }
  }
  
  # Process individual structures (if they exist separately)
  if (length(outstruct$indivBasisMap) > 0) {
    for (id in names(outstruct$indivBasisMap)) {
      mat <- outstruct$indivBasisMap[[id]]
      
      if (!is.null(mat) && ncol(mat) > 0) {
        # Get block name for individual structure
        block_idx <- outstruct$keyIdxMap[[id]][1]  # Individual structures have only one block
        block_name <- dataname[block_idx]
        
        # Create column names like "RNA-Individual-1", "PRO-Individual-2", etc.
        for (rank_idx in 1:ncol(mat)) {
          col_name <- paste0(block_name, "-Individual-", rank_idx)
          column_names <- c(column_names, col_name)
          score_columns[[col_name]] <- mat[, rank_idx]
        }
      }
    }
  }
  
  # Create the comprehensive matrix
  if (length(score_columns) > 0) {
    # Combine all score columns into a matrix
    sample_score_matrix <- do.call(cbind, score_columns)
    
    # Debug information
    if (iprint) {
      cat("Debug: score_columns length:", length(score_columns), "\\n")
      cat("Debug: column_names length:", length(column_names), "\\n")
      cat("Debug: matrix dimensions:", dim(sample_score_matrix), "\\n")
    }
    
    # Ensure column names match matrix dimensions
    if (ncol(sample_score_matrix) == length(column_names)) {
      colnames(sample_score_matrix) <- column_names
    } else {
      if (iprint) {
        cat("Warning: Column names length (", length(column_names), 
            ") does not match matrix columns (", ncol(sample_score_matrix), ")\\n")
      }
      # Generate generic column names if there's a mismatch
      colnames(sample_score_matrix) <- paste0("Component_", 1:ncol(sample_score_matrix))
    }
    
    # Set row names to sample IDs if available
    if (!is.null(sample_ids)) {
      rownames(sample_score_matrix) <- sample_ids
    }
    
    # Add to output structure
    outstruct$sampleScoreMatrix <- sample_score_matrix
    
    if (iprint) {
      cat("Sample-score matrix created with dimensions:", dim(sample_score_matrix), "\\n")
      cat("Columns:", paste(colnames(sample_score_matrix), collapse = ", "), "\\n")
    }
  } else {
    outstruct$sampleScoreMatrix <- NULL
    if (iprint) {
      cat("No score matrices found to create sample-score matrix.\\n")
    }
  }

  # ---- Compute inverse loadings and recalculated scores ----
  if (iprint) {
    cat("Computing inverse loadings and recalculated scores...\\n")
  }
  
  # Initialize output structures
  outstruct$Loadings <- vector("list", nb)
  outstruct$Scores <- vector("list", nb)
  outstruct$LoadingsNames <- vector("list", nb)
  outstruct$names_vec <- vector("list", nb)
  names(outstruct$Loadings) <- dataname
  names(outstruct$Scores) <- dataname
  names(outstruct$LoadingsNames) <- dataname
  names(outstruct$names_vec) <- dataname
  
  # Helper function: computLoadings (exactly from CaseCOVID.Rmd)
  computLoadings <- function(divasRes, omic_block = 1) {
    
    # Step 1: Concatenate all loadings for the specified omic block
    all_loadings_list <- divasRes$matLoadings[[omic_block]]
    # Remove any NULL components
    valid_loadings <- all_loadings_list[!sapply(all_loadings_list, is.null)]
    newNames <- names(valid_loadings)
    newNames <- divasRes$keymapname[newNames]
    names(valid_loadings) <- newNames
    
    if (length(valid_loadings) == 0) {
      stop("No valid loadings found for this omic block")
    }
    
    # Step 2: Horizontally concatenate all loadings: [L_i,k]_{i|k∈i}
    L_concatenated <- do.call(cbind, valid_loadings)
    
    # Step 3: Compute generalized inverse of concatenated loadings
    L_concat_pinv_T <- t(ginv(L_concatenated))
    L_concat_pinv_T <- scale(L_concat_pinv_T, center = F, scale = colSums(L_concat_pinv_T^2)^(1/2))
    
    
    # Step 4: Add rownames and column names
    rownames(L_concat_pinv_T) <- rownames(L_concatenated)
    
    # Create column names based on data block combinations and component indices
    col_names <- c()
    for (i in 1:length(valid_loadings)) {
      loading_name <- names(valid_loadings)[i]  # This is the keymapname (e.g., "RNA+Protein")
      n_components <- ncol(as.matrix(valid_loadings[[i]]))
      
      # Generate column names like "RNA+Protein-1", "RNA+Protein-2", etc.
      component_names <- paste0(loading_name, "-", 1:n_components)
      col_names <- c(col_names, component_names)
    }
    # Set column names
    colnames(L_concat_pinv_T) <- col_names
    
    return(L_concat_pinv_T)
  }

  # Process each data block using computLoadings
  for (block_idx in 1:nb) {
    if (iprint) {
      cat("Processing block", block_idx, ":", dataname[block_idx], "...\\n")
    }
    
    # MASS is imported, so we can use it directly
    
    # Use computLoadings function
    tryCatch({
      newLoadings <- computLoadings(outstruct, omic_block = block_idx)
      
      # Store the inverse loadings as a nested list per block:
      # - First level: block name (already indexed by block_idx)
      # - Second level: component name (one column per rank), value is a one-column matrix
      col_names <- colnames(newLoadings)
      loading_list <- vector("list", length(col_names))
      names(loading_list) <- col_names
      for (jj in seq_along(col_names)) {
        loading_list[[jj]] <- as.matrix(newLoadings[, jj, drop = FALSE])
        colnames(loading_list[[jj]]) <- col_names[jj]
      }
      outstruct$Loadings[[block_idx]] <- loading_list
      outstruct$LoadingsNames[[block_idx]] <- names(loading_list)
      outstruct$names_vec[[block_idx]] <- names(loading_list)
      
      # Compute recalculated scores following CaseCOVID.Rmd:
      # Shat <- crossprod(XtrainCent, newLoadings)
      X_block <- as.matrix(datablock[[block_idx]])
      if (!is.null(sample_ids)) {
        X_block <- X_block[, sample_ids, drop = FALSE]
      }
      # Row centering (与CaseCOVID.Rmd一致: XtrainCent <- Xtrain - rowMeans(Xtrain))
      X_block_cent <- X_block - rowMeans(X_block)
      S_recalc <- crossprod(X_block_cent, newLoadings)
      # Column normalisation to unit norm (与CaseCOVID.Rmd一致)
      S_recalc <- t(t(S_recalc)/colSums(S_recalc^2)**0.5)
      
      # Add sample names as rownames
      if (!is.null(sample_ids)) {
        rownames(S_recalc) <- sample_ids
      }
      colnames(S_recalc) <- col_names
      
      # Store the recalculated scores
      outstruct$Scores[[block_idx]] <- S_recalc
      
      if (iprint) {
        cat("  Inverse loadings computed with dimensions:", dim(newLoadings), "\\n")
        cat("  Recalculated scores computed with dimensions:", dim(S_recalc), "\\n")
      }
    }, error = function(e) {
      if (iprint) {
        cat("  Error processing block", block_idx, ":", e$message, "\\n")
      }
      outstruct$Loadings[[block_idx]] <- NULL
      outstruct$Scores[[block_idx]] <- NULL
    })
  }

  if (iprint) {
    cat("DIVAS is complete.\\n")
  }

  # Reorder/compact return according to ReturnDetail
  if (!ReturnDetail) {
    # Compact: keep only the most relevant elements in preferred order
    compact <- list(
      Scores = outstruct$Scores,
      Loadings = outstruct$Loadings,
      jointBasisMap = outstruct$jointBasisMap,
      matLoadings = outstruct$matLoadings,
      keymapname = outstruct$keymapname
    )
    return(compact)
  } else {
    # Full details but reorder to prioritize the key elements first
    prioritized <- list(
      Scores = outstruct$Scores,
      Loadings = outstruct$Loadings,
      jointBasisMap = outstruct$jointBasisMap,
      matLoadings = outstruct$matLoadings,
      keymapname = outstruct$keymapname
    )
    # Append the rest of the fields preserving originals
    remaining_names <- setdiff(names(outstruct), names(prioritized))
    for (nm in remaining_names) {
      prioritized[[nm]] <- outstruct[[nm]]
    }
    return(prioritized)
  }
}

