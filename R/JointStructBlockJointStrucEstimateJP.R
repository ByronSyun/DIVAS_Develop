#-----------------------------------------------------------------------------
Idx2numMJ <- function(blockIn) {
  if (!is.logical(blockIn)) {
    stop("Input must be a logical vector.")
  }

  nb <- length(blockIn)
  t <- 0
  for (i in 1:nb) {
    if (blockIn[i]) {
      t <- t + 2^(i - 1)
    }
  }
  return(t)
}



#-----------------------------------------------------------------------------
projAngleMJ <- function(x, V) {
  # Project x onto the subspace spanned by V
  px <- V %*% t(V) %*% x

  # Calculate the angle between the vector x and its projection px
  angle <- acos(sum(px * x) / (norm(px, type = "2") * norm(x, type = "2"))) * 180 / pi

  return(angle)
}

ccpOutAnalysisMJ <- function(cache_v, VBars) {
  # Number of adjusted signal row spaces
  nb <- length(VBars)
  # Number of cached optimization vectors
  T <- length(cache_v)
  angleHats <- vector("list", nb)


  for (ib in 1:nb) {
    # Initialize angles with -1 for each iteration
    angles <- rep(-1, T)
    # Loop over each cached optimization vector
    for (t in 1:T) {
      angles[t] <- projAngleMJ(cache_v[[t]], VBars[[ib]])
    }
    angleHats[[ib]] <- angles
  }

  return(angleHats)
}



#-----------------------------------------------------------------------------
ccpOutVisualMJ <- function(angleHats, phiBars, dataname, iprint = NULL, figdir = NULL, figname = NULL) {
  # Set default figure name if not provided
  if (is.null(figname) || figname == "") {
    figname <- "opt_progress"
  }

  nb <- length(phiBars)
  T <- length(angleHats[[1]])
  idx <- 1:T


  #par(mfrow = c(1, nb), oma = c(0, 0, 2, 0), mar = c(1, 1, 1, 1))
  graphics::par(mfrow = c(1, nb), oma = c(0, 0, 1, 0), mar = c(2, 2, 1, 1))
  for (ib in 1:nb) {
    # for each data block
    plot(idx, angleHats[[ib]], type = "l", lwd = 2,
         xlab = "Index", ylab = "Projected Angle",
         main = paste0(dataname[[ib]], "\n", figname),
         xlim = c(1, T), ylim = c(0, max(angleHats[[ib]], phiBars[ib], na.rm = TRUE)))

    # Add a horizontal line for phiBars
    graphics::abline(h = phiBars[ib], col = "green", lty = 2, lwd = 2)

    graphics::legend("topright", legend = c(paste0("Estimated Angle ", ib), paste0("Perturbation Angle ", ib)),
           col = c("black", "green"), lty = c(1, 2), lwd = c(2, 2), bty = "n")
  }


  if (!is.null(iprint) && iprint == 1) {


    if(!is.null(figdir)){# If figdir is provided


      if (!dir.exists(figdir)) {# If figdir doesn't exist, set it to the current working directory

        message("No valid figure directory found! Saving to the current folder.")
        figdir <- getwd()  # Use the current working directory as a fallback
      }

      savestr <- file.path(figdir, paste0(figname, ".png"))

      tryCatch({
        grDevices::png(savestr, width = 1500, height = 500)

        graphics::par(mfrow = c(1, nb), oma = c(0, 0, 2, 0), mar = c(1, 1, 1, 1))
        for (ib in 1:nb) {
          plot(idx, angleHats[[ib]], type = "l", lwd = 2,
               xlab = "Index", ylab = "Projected Angle",
               main = paste0(dataname[[ib]], "\n", figname),
               xlim = c(1, T), ylim = c(0, max(angleHats[[ib]], phiBars[ib], na.rm = TRUE)))
          graphics::abline(h = phiBars[ib], col = "green", lty = 2, lwd = 2)
        }
        grDevices::dev.off()
        message("Figure saved successfully in: ", savestr)
      }, error = function(e) {
        message("Failed to save figures! Error: ", e)
      })
    } else {# figdir not provided, just print it

      tryCatch({
        graphics::par(mfrow = c(1, nb), oma = c(0, 0, 2, 0), mar = c(1, 1, 1, 1))
        for (ib in 1:nb) {
          plot(idx, angleHats[[ib]], type = "l", lwd = 2,
               xlab = "Index", ylab = "Projected Angle",
               main = paste0(dataname[[ib]], "\n", figname),
               xlim = c(1, T), ylim = c(0, max(angleHats[[ib]], phiBars[ib], na.rm = TRUE)))
          graphics::abline(h = phiBars[ib], col = "green", lty = 2, lwd = 2)
        }

      }, error = function(e) {
        message("Failed to plot figures! Error: ", e)
      })
    }

  }
}





### Main function
#-----------------------------------------------------------------------------
# Depends on penaltyCCPJPEarlyStop,
# Depends on ccpOutVisualMJ, Idx2numMJ (defined above)
BlockJointStrucEstimateJP <- function(
    blockIn, dataname, VBars, phiBars, rBars, curRanks, outMap,
    theta0 = 45, optArgin = list(), iprint = F, figdir = NULL
) {

  nb <- length(blockIn)
  allIdx <- 1:nb
  blockIdx <- allIdx[blockIn]
  blockName <- dataname[blockIn]

  cat(paste("Find joint structure shared only among", paste(blockName, collapse = ", "), ".\n"))

  n <- nrow(VBars[[1]])
  blockLen <- sum(blockIn)


  Mo1 <- NULL
  Mo2 <- NULL
  Qc1 <- vector("list", nb)
  Qc2 <- vector("list", nb)


  for (ib in 1:nb) {
    if (blockIn[ib]) {
      Mo2 <- cbind(Mo2, VBars[[ib]])
      Qc1[[ib]] <- diag(n)
      # In MATLAB, 'cosd()' takes degrees, so convert phiBars to radians in R
      Qc2[[ib]] <- VBars[[ib]] %*% t(VBars[[ib]]) / cos(phiBars[ib] * pi / 180)^2
    } else {
      # Mo1 <- cbind(Mo1, VBars[[ib]])
      Qc1[[ib]] <- VBars[[ib]] %*% t(VBars[[ib]]) / cos(phiBars[ib] * pi / 180)^2
      Qc2[[ib]] <- diag(n)
    }
  }


  Qo1 <- if (is.null(Mo1)) diag(n) * 1e-6 else Mo1 %*% t(Mo1)
  Qo2 <- if (is.null(Mo2)) diag(n) * 1e-6 else Mo2 %*% t(Mo2)

  Vorth <- NULL
  Vnorth <- NULL
  if (length(Vorth) == 0 || is.null(Vorth)) {
    Vorth <- matrix(0, n, 1)
  }

  # for (len in nb: (blockLen + 1)) {
  #   if (len > length(allIdx)) {  # Skip if len is greater than available indices
  #     next
  #   }
  #   lenIdces <- combn(allIdx, len)
  #   for (i in 1:ncol(lenIdces)) {
  #     bkIdx <- lenIdces[, i]
  #     bkIn <- allIdx %in% bkIdx
  #     t <- Idx2numMJ(bkIn)
  #
  #     if (!is.element(as.character(t), names(outMap))) next
  #
  #     if (all(blockIdx %in% bkIdx)) {
  #       Vorth <- cbind(Vorth, outMap[[as.character(t)]])
  #     } else {
  #       Vnorth <- cbind(Vnorth, outMap[[as.character(t)]])
  #     }
  #   }
  # }
  for (len in nb:(blockLen + 1)) {
    if (len > length(allIdx)) next
    lenIdces <- utils::combn(allIdx, len)
    for (i in 1:ncol(lenIdces)) {
      bkIdx <- lenIdces[, i]
      bkIn <- allIdx %in% bkIdx
      t <- Idx2numMJ(bkIn)

      if (!is.element(as.character(t), names(outMap))) next

      if (all(blockIdx %in% bkIdx)) {
        Vorth <- cbind(Vorth, outMap[[as.character(t)]])
      } else {
        Vnorth <- cbind(Vnorth, outMap[[as.character(t)]])
      }
    }
  }

  if (!is.null(Vnorth) && ncol(Vnorth) > 0) {
    Qc1[[length(Qc1) + 1]] <- Vnorth %*% t(Vnorth) / cos(theta0)^2
    Qc2[[length(Qc2) + 1]] <- diag(n)
  }

  # rBars <- matrix(rBars, nrow = length(rBars), ncol = 1)

  searchNext <- TRUE
  #V0 <- svd(Qo2)$v[, 1:max(rBars[blockIn])]
  V0 <- RSpectra::svds(Qo2, k = max(rBars[blockIn]))$v

  Vi <- matrix(0, nrow = nrow(V0), ncol = 0)
  #angles <- matrix(90, nrow = nb, ncol = max(ncol(V0), 1))
  angles <- matrix(0, nrow = nb, ncol = ncol(V0))


  j <- 0
  while (searchNext) {
    j <- j + 1
    cat(sprintf("Search Direction %d:\n", j))
    Vorth <- cbind(Vorth, Vi)

    result <- penaltyCCPJPEarlyStop(V0[, j], Qo1, Qo2, Qc1, Qc2, Vorth, optArgin)
    # print('result')
    # print(result)
    opt_v <- result$opt_v
    cache_v <- result$cache_v
    converge <- result$converge

    angleHats <- ccpOutAnalysisMJ(cache_v, VBars)
    figname <- paste(paste(blockName, collapse = "-"), "-joint-optV", j, sep = "")
    ccpOutVisualMJ(angleHats, phiBars, dataname, iprint, figdir, figname)

    for (ib in 1:nb) {
      if (j > ncol(angles)) {
        angles <- cbind(angles, matrix(90, nrow = nb, ncol = 1))
      }
      angles[ib, j] <- utils::tail(angleHats[[ib]], 1)
    }

    if (!converge) {
      cat(sprintf("Direction %d does not converge. Stop searching current joint block.\n", j))
      break
    }

    cat(sprintf("Direction %d converges.\n", j))
    Vi <- cbind(Vi, opt_v)
    curRanks <- curRanks + blockIn

    if (any(curRanks + blockIn > rBars)) {
      cat("There is no room for searching next direction. Stop searching current joint block.\n")
      searchNext <- FALSE
    } else {
      cat("There is room for searching next direction. Continue...\n")
    }
  }

  if(ncol(Vi) == 0){
    angles <- angles[,1]
  } else {
    angles <- angles[, 1:(ncol(Vi) + 1 * !any(curRanks + blockIn > rBars))]
  }

  return(list(Vi = Vi, curRanks = curRanks, angles = angles))
}


