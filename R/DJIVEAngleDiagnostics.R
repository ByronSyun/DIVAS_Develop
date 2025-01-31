takeNormOfEachColumnJP <- function(inmat) {
  d <- nrow(inmat)
  sumsqs <- sqrt(colSums(inmat^2))
  outmat <- inmat / matrix(rep(sumsqs, each = d), nrow = d)
  return(outmat)
}


#' Calculate Random Direction Angles
#'
#' Computes angles between random vectors and their projections onto first r components
#'
#' @param n Dimension of the random vector
#' @param r Number of components to project onto
#' @param nsim Number of simulations to run
#'
#' @return Vector of angles in degrees
randDirAngleMJ <- function(n, r, nsim) {
  angles <- numeric(nsim)
  for (i in 1:nsim) {
    vec <- rnorm(n)
    angles[i] <- acos(sum(vec[1:r]^2)^0.5 / sum(vec^2)^0.5) * 180 / pi
  }
  return(angles)
}



# load("~/Desktop/workspace.RData")
# titlestr = "Demo";

#' Create Diagnostic Plots for DJIVE Analysis
#'
#' @param datablock List of data blocks
#' @param dataname Vector of data block names
#' @param outstruct Output structure from DJIVE analysis
#' @param randseed Random seed for reproducibility
#' @param titlestr Title string for plots
#'
#' @return List of three ggplot objects: rank, score, and loading plots
#' @import matrixStats
#' @import ggplot2
#' @import abind
#' @importFrom grDevices rgb
#' @importFrom stats quantile
#' @export
DJIVEAngleDiagnosticJP <- function(
    datablock, dataname, outstruct, randseed, titlestr) {
  set.seed(randseed)

  outMap <- outstruct$jointBasisMap
  keyIdxMap <- outstruct$keyIdxMap
  rBars <- outstruct$rBars
  VBars <- outstruct$VBars
  UBars <- outstruct$UBars
  phiBars <- outstruct$phiBars
  psiBars <- outstruct$psiBars
  VVHatCacheBars <- outstruct$VVHatCacheBars
  UUHatCacheBars <- outstruct$UUHatCacheBars

  uniqueStr <- titlestr
  logENC <- TRUE
  trueTraitKeys <- names(outstruct$jointBasisMap)#same

  n <- nrow(outMap[[trueTraitKeys[1]]])
  nb <- length(datablock)
  ds <- numeric(nb)
  randAngleTraits <- rep(90, nb)
  randAngleObjects <- rep(90, nb)
  rankGothV <- numeric(nb)
  rankGothL <- numeric(nb)
  rankMax <- numeric(nb)

  outstruct$matLoadings <- lapply(outstruct$matLoadings, function(ib) {
    lapply(ib, function(val) {
      if (is.vector(val)) {
        matrix(val, ncol = 1)
      } else {
        val
      }
    })
  })

  for (ib in seq_len(nb)) {
    trueObjKeys <- names(outstruct$matLoadings[[ib]])#same but 756
    ds[ib] <- nrow(outstruct$matLoadings[[ib]][[trueObjKeys[1]]])
    randAngleCache <- randDirAngleMJ(n, rBars[ib], 1000)
    randAngleCacheLoad <- randDirAngleMJ(ds[ib], rBars[ib], 1000)
    randAngleTraits[ib] <- quantile(randAngleCache, 0.05)#small diff
    randAngleObjects[ib] <- quantile(randAngleCacheLoad, 0.05)#small diff

    #under check
    gothVi <- lapply(names(outstruct$matLoadings[[ib]]), function(key) outstruct$jointBasisMap[[key]])
    gothLi <- lapply(outstruct$matLoadings[[ib]], as.matrix)
    gothV <- do.call(cbind, gothVi)
    gothL <- do.call(cbind, gothLi)
    ###

    rankGothV[ib] <- qr(gothV)$rank
    rankGothL[ib] <- qr(gothL)$rank

    rankMax[ib] <- min(n, ds[ib])
  }

  # Subgroup Rank Diagram

  # Identify each binary encoding by its number of blocks and its size as a
  # subspace
  rankIm <- array(1, dim = c(nb, 2^nb - 1, 3))
  sspSize <- numeric(2^nb - 1)
  sspCols <- array(0, dim = c(1, 2^nb - 1, 3))
  numJ <- numeric(2^nb - 1)
  sizeCols <- matrix(c(
    0, 1, 0,  # 3-Way blue
    1, 0, 0,  # 2-Way red
    0.4, 0.4, 1,  # other color
    0.5, 0.5, 0.5,  # grey
    1, 0, 1
  ), nrow = 5, byrow = TRUE)

  for (k in seq_len(2^nb - 1)) {
    key <- as.character(k)
    if (key %in% names(outMap)) {  #same
      numJ[k] <- length(keyIdxMap[[key]])
      sspSize[k] <- ncol(outMap[[key]])
      sspCols[1, k, ] <- sizeCols[numJ[k], ]#same
      for (idx in keyIdxMap[[key]]) {
        rankIm[idx, k, ] <- sspCols[1, k, ] # do not use rep, keep dimensions same
      }
    } else {
      bb <- seq_len(nb)
      binBlock <- rep(0, nb)
      rem <- k
      for (p in rev(seq_len(nb))) {
        binBlock[p] <- rem %/% (2^(p - 1))
        rem <- rem %% (2^(p - 1))
      }
      binBlock <- as.logical(binBlock)
      kimk <- bb[binBlock]
      keyIdxMap[[key]] <- kimk #same
      numJ[k] <- sum(binBlock)
      sspSize[k] <- 0
      sspCols[1, k, ] <- c(0.8, 0.8, 0.8)
      for (idx in kimk) {
        rankIm[idx, k, ] <- sspCols[1, k, ] # dont use rep, keep dim same
      }
    }
  }
  ##############above correct

  # Tweak the colors to weight them by subspace size
  sorted_indices <- order(numJ, decreasing = TRUE)
  szInd <- order(numJ, decreasing = TRUE)
  numJ_s <- numJ[szInd]
  sspSize_s <- sspSize[sorted_indices]
  ## sspCols_s <- sspCols[, sorted_indices, ] #(dim 73, not 173)
  sspCols_s <- sspCols[, sorted_indices, , drop = FALSE] #dim 1 7 3
  rankIm_s_solid <- rankIm[, sorted_indices, ]
  rankIm_s <- rankIm[, sorted_indices, ] #same
  # Add an additional column of ones for spacing
  rankIm_s <- abind::abind(rankIm_s, array(1, dim = c(nb, 1, 3)), along = 2)

  ncs <- 1:(2^nb - 1)
  ins <- 2^nb

  for (b in rev(seq_len(nb))) {
    ins <- ins - choose(nb, b)
    rankIm_s <- abind::abind(
      rankIm_s[, 1:ins, ],
      array(1, dim = c(nb, 1, 3)),
      rankIm_s[, (ins + 1):dim(rankIm_s)[2], ],
      along = 2
    )
  }

  textInds <- c()
  runStart <- 1
  runEnds <- c(1)

  for (b in seq_len(nb)) {
    runEnds[b + 1] <- runEnds[b] + choose(nb, b)
    textInds <- c(textInds, runStart:(runStart - 1 + choose(nb, b - 1)))
    runStart <- runStart + 1 + choose(nb, b - 1) #same
  }
  runEnds <- runEnds[1:nb]

  ncrs <- numeric(nb)
  midpts <- numeric(nb)
  xSum <- 0
  xticklabs <- vector("list", nb)

  for (b in seq_len(nb)) {
    ncrs[b] <- choose(nb, b - 1)
    midpts[b] <- mean(textInds[(xSum + 1):(xSum + ncrs[b])])
    xSum <- xSum + ncrs[b]
    xticklabs[[nb - b + 1]] <- paste0(b, "-Way")
  }
  xticklabs[[nb + 1]] <- "Ranks"
  fontsize = 28
  ##############above correct


  # df for store data
  plot_df <- expand.grid(
    row = 1:nrow(rankIm_s),
    col = 1:ncol(rankIm_s)
  )
  plot_df$r <- as.vector(rankIm_s[,,1])
  plot_df$g <- as.vector(rankIm_s[,,2])
  plot_df$b <- as.vector(rankIm_s[,,3])

  ######################### Rank Breakdown fig #########################
  plot_rank <- ggplot2::ggplot(plot_df, ggplot2::aes(x = col, y = row)) +
    ggplot2::geom_tile(ggplot2::aes(fill = I(rgb(r, g, b)))) +
    ggplot2::labs(title = paste("Rank Breakdown by Joint Structure:\n", uniqueStr)) +
    ggplot2::scale_y_reverse(
      breaks = 1:nb,
      labels = dataname,
      expand = c(0, 0)
    ) +
    ggplot2::scale_x_continuous(
      breaks = c(midpts, ncol(rankIm_s)),
      labels = xticklabs,
      expand = c(0, 0)
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = 10, hjust = 0.5),
      axis.text.x = ggplot2::element_text(size = 8, angle = 45, hjust = 1),
      axis.text.y = ggplot2::element_text(size = 8),
      panel.grid = ggplot2::element_blank(),
      legend.position = "none",
      plot.background = ggplot2::element_rect(fill = "white", color = NA),
      panel.background = ggplot2::element_rect(fill = "white", color = NA),
      axis.line = ggplot2::element_blank()
    )

  for (k in 1:(2^nb+nb)) {
    plot_rank <- plot_rank +
      geom_vline(xintercept = k + 0.5, color = "black", size = 0.25)
  }

  xSum <- 0
  for (b in 1:nb) {
    for (bb in 1:nb) {
      plot_rank <- plot_rank +
        geom_segment(
          x = textInds[xSum+1] - 0.5,
          xend = textInds[xSum+ncrs[b]] + 0.5,
          y = bb - 0.5,
          yend = bb - 0.5,
          color = "black"
        )
    }
    # rBars
    plot_rank <- plot_rank +
      annotate(
        "text",
        x = 2^nb + nb,
        y = b,
        label = rBars[b],
        size = fontsize/4,
        hjust = 0.5,
        color = "black"
      )

    xSum <- xSum + ncrs[b]
    # add margin
    plot_rank <- plot_rank +
      geom_segment(
        x = 2^nb + nb - 0.5,
        xend = 2^nb + nb + 0.5,
        y = b - 0.5,
        yend = b - 0.5,
        color = "black"
      )
  }

  # sspSize
  for (k in 1:(2^nb-1)) {
    k_s <- szInd[k]
    for (b in 1:nb) {
      if (b %in% keyIdxMap[[as.character(k_s)]]) {
        plot_rank <- plot_rank +
          annotate(
            "text",
            x = textInds[k],
            y = b,
            label = sspSize[k_s],
            size = fontsize/4,
            hjust = 0.5,
            color = "black"
          )
      }
    }
  }

  # add grid
  plot_rank <- plot_rank +
    geom_hline(yintercept = seq(0.5, nb + 0.5, by = 1), color = "black", size = 0.25) +
    geom_vline(xintercept = seq(0.5, ncol(rankIm_s) + 0.5, by = 1), color = "black", size = 0.25)
  #################################

  # Initialize maps (using named lists to mimic MATLAB containers.Map)
  thetaTwoStars <- list()
  upperBounds <- list()
  lowerBounds <- list()
  midPoints <- list()

  thetaTwoStarsLoad <- list()
  upperBoundsLoad <- list()
  lowerBoundsLoad <- list()
  midPointsLoad <- list()

  for (k in seq_len(2^nb - 1)) {
    cat(sprintf("Starting binary code %d\n", k))
    key <- as.character(k)

    if (key %in% names(outMap)) {
      jointVec <- outMap[[key]]
      rs <- ncol(jointVec)
      thetaTwos <- matrix(0, nrow = nb, ncol = rs)
      thetaTwosLoad <- matrix(0, nrow = nb, ncol = rs)
      midpoints <- matrix(0, nrow = nb, ncol = rs)
      midpointsLoad <- matrix(0, nrow = nb, ncol = rs)

      for (ib in seq_len(nb)) {
        if (any(VVHatCacheBars[[ib]][[1]] != 0)) {
          nsim <- length(VVHatCacheBars[[ib]])

          # Load vectors
          if (key %in% names(outstruct$matLoadings[[ib]])) {
            loadVec <- outstruct$matLoadings[[ib]][[key]]
            loadVec <- takeNormOfEachColumnJP(loadVec)
          } else {
            loadVec <- matrix(0, nrow = nrow(datablock[[ib]]), ncol = rs)
          } #loadVec check again

          omegaHat <- t(VBars[[ib]]) %*% jointVec
          omegaHatLoad <- t(UBars[[ib]]) %*% loadVec

          # Compute midpoints
          for (r in seq_len(rs)) {
            midpoints[ib, r] <- acosd(min(1, max(-1, svd(omegaHat[, r])$d[1])))
            midpointsLoad[ib, r] <- acosd(min(1, max(-1, svd(omegaHatLoad[, r])$d[1])))
          }

          # Initialize bootstrapping matrices
          thetaTwoStarsBoot <- matrix(0, nrow = nsim, ncol = rs)
          precos <- matrix(0, nrow = nsim, ncol = rs)
          thetaTwoStarsBootLoad <- matrix(0, nrow = nsim, ncol = rs)
          precosLoad <- matrix(0, nrow = nsim, ncol = rs)

          bootCache <- VVHatCacheBars[[ib]] #need check. again
          bootCacheLoad <- UUHatCacheBars[[ib]]

          cat("Progress Through Bootstrapped Matrices:\n")
          cat(rep(".", nsim), "\n")

          # Parallel for loop (use foreach or similar in R for actual parallelism)
          for (i in seq_len(nsim)) {
            bootMat <- bootCache[[i]]
            bootMatLoad <- bootCacheLoad[[i]]

            if (is.null(bootMat)) {
              warning("bootMat is NULL, skipping iteration.")
              next
            }
            if (ncol(bootMat) != nrow(omegaHat)) {
              stop(sprintf("Dimension mismatch: ncol(bootMat) = %d, nrow(omegaHat) = %d", ncol(bootMat), nrow(omegaHat)))
            }

            precos[i, ] <- sqrt(colSums((bootMat %*% omegaHat)^2)) / sqrt(colSums(omegaHat^2)) #same
            precosLoad[i, ] <- sqrt(colSums((bootMatLoad %*% omegaHatLoad)^2)) / sqrt(colSums(omegaHatLoad^2))#near same

            thetaTwoStarsBoot[i, ] <- acosd(sqrt(colSums((bootMat %*% omegaHat)^2)) / sqrt(colSums(omegaHat^2))) #barely same
            thetaTwoStarsBootLoad[i, ] <- acosd(sqrt(colSums((bootMatLoad %*% omegaHatLoad)^2)) / sqrt(colSums(omegaHatLoad^2)))#near same
            cat("\b|")
          }
          cat("\n")

          # # Compute quantiles #same when k=4~9, checked all
          thetaTwos[ib, ] <- apply(thetaTwoStarsBoot, 2, function(x) quantile(x, 0.95))
          #thetaTwosLoad[ib, ] <- apply(thetaTwoStarsBootLoad, 2, function(x) quantile(x, 0.95))
          thetaTwosLoad[ib, ] <- apply(thetaTwoStarsBootLoad, 2, function(x) {
            if (all(is.na(x))) {
              return(NA)
            } else {
              quantile(x, 0.95, na.rm = FALSE)  # for keep NA
            }
          })
        }
      }
      # Save results into the maps
      thetaTwoStars[[key]] <- thetaTwos
      upperbounds <- pmin(thetaTwos + midpoints, 90)
      upperBounds[[key]] <- upperbounds
      lowerbounds <- pmax(midpoints - matrix(rep(phiBars, rs), nrow = nb, byrow = TRUE), 0)
      lowerBounds[[key]] <- lowerbounds
      midPoints[[key]] <- midpoints

      thetaTwoStarsLoad[[key]] <- thetaTwosLoad
      upperboundsLoad <- pmin(thetaTwosLoad + midpointsLoad, 90)
      upperBoundsLoad[[key]] <- upperboundsLoad
      lowerboundsLoad <- pmax(midpointsLoad - matrix(rep(psiBars, rs), nrow = nb, byrow = TRUE), 0)
      lowerBoundsLoad[[key]] <- lowerboundsLoad
      midPointsLoad[[key]] <- midpointsLoad
    }
    cat(sprintf("Finished binary code %d\n", k))
  }


  ######################## plot_score ########################
  # Create last row
  lastRow <- array(1, dim = c(1, ncol(rankIm_s), 3))
  lastRow[1, textInds, ] <- sspCols_s
  # Merge data
  plotData <- abind::abind(rankIm_s, lastRow, along = 1)
  plot_df <- data.frame(
    row = rep(1:nrow(plotData), ncol(plotData)),
    col = rep(1:ncol(plotData), each = nrow(plotData)),
    r = as.vector(plotData[,,1]),
    g = as.vector(plotData[,,2]),
    b = as.vector(plotData[,,3])
  )

  plot_score <- ggplot2::ggplot(plot_df, ggplot2::aes(x = col, y = row)) +
    ggplot2::geom_tile(ggplot2::aes(fill = I(rgb(r, g, b)))) +
    ggplot2::labs(title = paste("Joint Structure Score Diagnostics:\n", uniqueStr)) +
    # axis set
    ggplot2::scale_y_reverse(
      breaks = 1:(nb+1),
      labels = c(dataname, "Effective\nNumber\nof Cases"),
      expand = c(0, 0)
    ) +
    ggplot2::scale_x_continuous(
      breaks = c(midpts, ncol(rankIm_s)),
      labels = xticklabs,
      expand = c(0, 0)
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = 10, hjust = 0.5),
      axis.text.x = ggplot2::element_text(size = 8, angle = 45, hjust = 1),
      axis.text.y = ggplot2::element_text(size = 8),
      axis.title = ggplot2::element_text(size = 8)
    )

  # Grid
  plot_score <- plot_score +
    geom_vline(xintercept = seq(0.5, ncol(plotData) + 0.5, 1),
               color = "black", size = 0.25) +
    geom_hline(yintercept = seq(0.5, nrow(plotData) + 0.5, 1),
               color = "black", size = 0.25)

  for (k in 1:(2^nb-1)) {
    k_s <- szInd[k]
    for (b in 1:nb) {
      if (b %in% keyIdxMap[[as.character(k_s)]]) {
        plot_score <- plot_score +
          ggplot2::annotate("text",
                            x = textInds[k],
                            y = b,
                            label = as.character(sspSize[k_s]),
                            size = 3,
                            color = "black")
      }
    }
  }

  # Ranks
  for (b in 1:nb) {
    plot_score <- plot_score +
      ggplot2::annotate("text",
                        x = ncol(rankIm_s),
                        y = b,
                        label = paste(rankGothV[b], rBars[b], rankMax[b], sep = "\n"),
                        size = 2.5,
                        color = "black")
  }

  segment_data <- data.frame(
    x = 0.5,
    xend = ncol(plotData) + 0.5,
    y = nrow(plotData) - 0.5,
    yend = nrow(plotData) - 0.5
  )

  plot_score <- plot_score +
    geom_segment(
      data = segment_data,
      aes(x = x, xend = xend, y = y, yend = yend),
      color = rgb(0.4, 0.4, 0.4),
      size = 0.5
    ) +
    geom_segment(
      data = data.frame(
        x = 0.5,
        xend = ncol(plotData) + 0.5,
        y = nrow(plotData) - 0.45,
        yend = nrow(plotData) - 0.45
      ),
      aes(x = x, xend = xend, y = y, yend = yend),
      color = rgb(0.4, 0.4, 0.4),
      size = 2
    )

  # fig output size
  options(repr.plot.width = 8, repr.plot.height = 6)

  for (k in 1:(2^nb-1)) {
    k_s <- szInd[k]
    k_p <- textInds[k]

    if (k_s %in% names(outMap)) {
      ddExtend <- 0.5

      if (k %in% runEnds) {
        for (b in 1:nb) {
          plot_score <- plot_score +
            ggplot2::annotate("text",
                              x = k_p + 0.85,
                              y = -phiBars[b]/90 + b + 0.5,
                              label = paste0(round(phiBars[b], 1), "."),
                              size = fontsize/10,
                              color = "black") +
            ggplot2::annotate("text",
                              x = k_p + 1.05,
                              y = -randAngleTraits[b]/90 + b + 0.5,
                              label = paste0(round(randAngleTraits[b], 1), "."),
                              size = fontsize/10,
                              color = "black")
        }
        ddExtend <- 0.72
      }
      xspan <- seq(k_p - 0.5, k_p + 0.5, length.out = sspSize[k_s] + 2)
      xspan <- xspan[2:(sspSize[k_s] + 1)]

      angleMat <- midPoints[[as.character(k_s)]]
      if (ncol(angleMat) > sspSize[k_s]) {
        angleMat <- angleMat[, 1:sspSize[k_s]]
      }
      upperMat <- upperBounds[[as.character(k_s)]]
      lowerMat <- lowerBounds[[as.character(k_s)]]
      thetaTwos <- thetaTwoStars[[as.character(k_s)]]
      for (b in 1:nb) {
        # midpoint (x)
        plot_score <- plot_score +
          geom_point(
            data = data.frame(x = xspan, y = -angleMat[b,]/90 + b + 0.5),
            aes(x = x, y = y),
            shape = 4,  # x shape
            size = 1.5,
            color = "black"
          )
        # upper bound ( solid dot)
        if (sum(sum(VVHatCacheBars[[b]][[1]] != 0)) != 0) {
          plot_score <- plot_score +
            geom_point(
              data = data.frame(x = xspan, y = -upperMat[b,]/90 + b + 0.5),
              aes(x = x, y = y),
              shape = 16,  # solid dot
              size = 1,
              color = "black"
            )
        }
        plot_score <- plot_score +
          geom_line(
            data = data.frame(
              x = c(k_p - 0.5, k_p + 0.5),
              y = -rep(phiBars[b], 2)/90 + b + 0.5
            ),
            aes(x = x, y = y),
            linetype = "dashed",
            color = "black"
          ) +
          geom_line(
            data = data.frame(
              x = c(k_p - 0.5, k_p + ddExtend),
              y = -rep(randAngleTraits[b], 2)/90 + b + 0.5
            ),
            aes(x = x, y = y),
            linetype = "dotdash",
            color = "black"
          )
      }
    }
  }
  # Effective Sample Size
  essRoot <- ceiling(n^(1/4))
  for (k in 1:(2^nb-1)) {
    k_s <- szInd[k]
    k_p <- textInds[k]
    if (k_s %in% names(outMap)) {
      xspan <- seq(k_p - 0.5, k_p + 0.5, length.out = sspSize[k_s] + 2)
      xspan <- xspan[2:(sspSize[k_s] + 1)]
      effSampSizes <- 1/colSums(outMap[[as.character(k_s)]]^4)
      if (logENC) {
        plot_score <- plot_score +
          geom_point(
            data = data.frame(x = xspan, y = -0.9 * log(effSampSizes)/log(n) + nb + 1 + 0.5),
            aes(x = x, y = y),
            shape = 3,    # + shape
            size = 0.5,   # keep small
            color = "black"
          )
        y_positions <- -0.9 * log(c(essRoot, essRoot^2, essRoot^3))/log(n) + nb + 1 + 0.5
        for (y_pos in y_positions) {
          plot_score <- plot_score +
            geom_line(
              data = data.frame(
                x = c(k_p - 0.5, k_p + 0.5),
                y = rep(y_pos, 2)
              ),
              aes(x = x, y = y),
              linetype = "dashed",
              color = "black"
            )
        }
        if (k %in% runEnds) {
          plot_score <- plot_score +
            ggplot2::annotate("text",
                              x = k_p + 0.85,
                              y = y_positions,
                              label = c(essRoot, essRoot^2, essRoot^3),
                              size = fontsize/10,
                              color = "black")
        }
      } else {
        plot_score <- plot_score +
          geom_point(
            data = data.frame(x = xspan, y = -0.9 * effSampSizes/n + nb + 1 + 0.5),
            aes(x = x, y = y),
            shape = 3,    # + shape
            size = 0.5,
            color = "black"
          )
        y_positions <- -0.9 * c(0.75, 0.50, 0.25) + nb + 1 + 0.5
        for (y_pos in y_positions) {
          plot_score <- plot_score +
            geom_line(
              data = data.frame(
                x = c(k_p - 0.5, k_p + 0.5),
                y = rep(y_pos, 2)
              ),
              aes(x = x, y = y),
              linetype = "dashed",
              color = "black"
            )
        }

        if (k %in% runEnds) {
          plot_score <- plot_score +
            ggplot2::annotate("text",
                              x = k_p + 0.85,
                              y = y_positions,
                              label = round(c(0.75, 0.50, 0.25) * n),
                              size = fontsize/10,
                              color = "black")
        }
      }
    }
  }



  ########################## loading plot ##############
  plot_loading <- ggplot2::ggplot(plot_df, ggplot2::aes(x = col, y = row)) +
    ggplot2::geom_tile(ggplot2::aes(fill = I(rgb(r, g, b)))) +
    ggplot2::labs(title = paste("Joint Structure Loadings Diagnostics:\n", uniqueStr)) +
    ggplot2::scale_y_reverse(
      breaks = 1:(nb+1),
      labels = c(dataname, "Effective\nContribution\nof Traits"),
      expand = c(0, 0)
    ) +
    ggplot2::scale_x_continuous(
      breaks = c(midpts, ncol(rankIm_s)),
      labels = xticklabs,
      expand = c(0, 0)
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = 10, hjust = 0.5),
      axis.text.x = ggplot2::element_text(size = 8, angle = 45, hjust = 1),
      axis.text.y = ggplot2::element_text(size = 8),
      axis.title = ggplot2::element_text(size = 8)
    )


  options(repr.plot.width = 8, repr.plot.height = 6)

  # add grid
  plot_loading <- plot_loading +
    geom_vline(xintercept = seq(0.5, ncol(plotData) + 0.5, 1),
               color = "black", size = 0.25) +
    geom_hline(yintercept = seq(0.5, nrow(plotData) + 0.5, 1),
               color = "black", size = 0.25)

  # add label
  for (k in 1:(2^nb-1)) {
    k_s <- szInd[k]
    for (b in 1:nb) {
      if (b %in% keyIdxMap[[as.character(k_s)]]) {
        plot_loading <- plot_loading +
          ggplot2::annotate("text",
                            x = textInds[k],
                            y = b,
                            label = as.character(sspSize[k_s]),
                            size = 3,
                            color = "black")
      }
    }
  }

  # Ranks col
  for (b in 1:nb) {
    plot_loading <- plot_loading +
      ggplot2::annotate("text",
                        x = ncol(rankIm_s),
                        y = b,
                        label = paste(rankGothV[b], rBars[b], rankMax[b], sep = "\n"),
                        size = 2.5,
                        color = "black")
  }


  segment_data <- data.frame(
    x = 0.5,
    xend = ncol(plotData) + 0.5,
    y = nrow(plotData) - 0.5,
    yend = nrow(plotData) - 0.5
  )

  plot_loading <- plot_loading +
    geom_segment(
      data = segment_data,
      aes(x = x, xend = xend, y = y, yend = yend),
      color = rgb(0.4, 0.4, 0.4),
      size = 0.5
    ) +
    geom_segment(
      data = data.frame(
        x = 0.5,
        xend = ncol(plotData) + 0.5,
        y = nrow(plotData) - 0.45,
        yend = nrow(plotData) - 0.45
      ),
      aes(x = x, xend = xend, y = y, yend = yend),
      color = rgb(0.4, 0.4, 0.4),
      size = 2
    )

  # add degree data
  for (k in 1:(2^nb-1)) {
    k_s <- szInd[k]
    k_p <- textInds[k]

    if (k_s %in% names(outMap)) {
      ddExtend <- 0.5

      # move degree slight right
      if (k %in% runEnds) {
        for (b in 1:nb) {
          plot_loading <- plot_loading +
            ggplot2::annotate("text",
                              x = k_p + 0.85,
                              y = -psiBars[b]/90 + b + 0.5,
                              label = paste0(round(psiBars[b], 1), "."),
                              size = fontsize/10,
                              color = "black") +
            ggplot2::annotate("text",
                              x = k_p + 1.05,
                              y = -randAngleObjects[b]/90 + b + 0.5,
                              label = paste0(round(randAngleObjects[b], 1), "."),
                              size = fontsize/10,
                              color = "black")
        }
        ddExtend <- 0.72
      }

      xspan <- seq(k_p - 0.5, k_p + 0.5, length.out = sspSize[k_s] + 2)
      xspan <- xspan[2:(sspSize[k_s] + 1)]

      if (as.character(k_s) %in% names(midPointsLoad)) {
        angleMat <- midPointsLoad[[as.character(k_s)]]
        if (ncol(angleMat) > sspSize[k_s]) {
          angleMat <- angleMat[, 1:sspSize[k_s]]
        }

        upperMat <- upperBoundsLoad[[as.character(k_s)]]

        for (b in 1:nb) {
          if (sum(sum(UUHatCacheBars[[b]][[1]] != 0)) != 0) {
            # filter NA to ssolve warning
            valid_points <- !is.na(upperMat[b,])
            if (any(valid_points)) {
              plot_loading <- plot_loading +
                geom_point(
                  data = data.frame(
                    x = xspan[valid_points],
                    y = -upperMat[b,valid_points]/90 + b + 0.5
                  ),
                  aes(x = x, y = y),
                  shape = 16,
                  size = 1,
                  color = "black"
                )
            }
          }

          if (as.character(k_s) %in% names(outstruct$matLoadings[[b]])) {
            # filter NA to ssolve warning
            valid_points <- !is.na(angleMat[b,])
            if (any(valid_points)) {
              plot_loading <- plot_loading +
                geom_point(
                  data = data.frame(
                    x = xspan[valid_points],
                    y = -angleMat[b,valid_points]/90 + b + 0.5
                  ),
                  aes(x = x, y = y),
                  shape = 4,
                  size = 1.5,
                  color = "black"
                )
            }

            plot_loading <- plot_loading +
              geom_line(
                data = data.frame(
                  x = c(k_p - 0.5, k_p + 0.5),
                  y = -rep(psiBars[b], 2)/90 + b + 0.5
                ),
                aes(x = x, y = y),
                linetype = "dashed",
                color = "black"
              ) +
              geom_line(
                data = data.frame(
                  x = c(k_p - 0.5, k_p + ddExtend),
                  y = -rep(randAngleObjects[b], 2)/90 + b + 0.5
                ),
                aes(x = x, y = y),
                linetype = "dotdash",
                color = "black"
              )
          }
        }
      }

      # % move to slightly right
      if (k %in% runEnds) {
        plot_loading <- plot_loading +
          ggplot2::annotate("text",
                            x = k_p + 0.85,
                            y = c(-0.9 * 0.75, -0.9 * 0.50, -0.9 * 0.25) + nb + 1 + 0.5,
                            label = c("75%", "50%", "25%"),
                            size = fontsize/10,
                            color = "black")
      }
    }
  }

  # Effective Sample Size
  for (k in 1:(2^nb-1)) {
    k_s <- szInd[k]
    k_p <- textInds[k]

    if (k_s %in% names(outMap)) {
      xspan <- seq(k_p - 0.5, k_p + 0.5, length.out = sspSize[k_s] + 2)
      xspan <- xspan[2:(sspSize[k_s] + 1)]

      for (ib in 1:nb) {
        if (as.character(k_s) %in% names(outstruct$matLoadings[[ib]])) {
          loadVec <- outstruct$matLoadings[[ib]][[as.character(k_s)]]
          loadVec <- takeNormOfEachColumnJP(loadVec)
          effSampSizes <- 1/colSums(loadVec^4)

          plot_loading <- plot_loading +
            ggplot2::annotate("text",
                              x = xspan,
                              y = -0.9 * effSampSizes/ds[ib] + nb + 1 + 0.5,
                              label = as.character(ib),
                              size = fontsize/10,
                              color = "black")
        }
      }
      # add referring line
      # TODO: improve more clear: eg, ways segment ways by emptyspace
      plot_loading <- plot_loading +
        geom_line(
          data = data.frame(
            x = c(k_p - 0.5, k_p + 0.5),
            y = rep(-0.9 * 0.75 + nb + 1 + 0.5, 2)
          ),
          aes(x = x, y = y),
          linetype = "dashed",
          color = "black"
        ) +
        geom_line(
          data = data.frame(
            x = c(k_p - 0.5, k_p + 0.5),
            y = rep(-0.9 * 0.50 + nb + 1 + 0.5, 2)
          ),
          aes(x = x, y = y),
          linetype = "dashed",
          color = "black"
        ) +
        geom_line(
          data = data.frame(
            x = c(k_p - 0.5, k_p + 0.5),
            y = rep(-0.9 * 0.25 + nb + 1 + 0.5, 2)
          ),
          aes(x = x, y = y),
          linetype = "dashed",
          color = "black"
        )
      if (k %in% runEnds) {
        plot_loading <- plot_loading +
          ggplot2::annotate("text",
                            x = k_p + 0.85,
                            y = c(-0.9 * 0.75, -0.9 * 0.50, -0.9 * 0.25) + nb + 1 + 0.5,
                            label = c("75%", "50%", "25%"),
                            size = fontsize/10,
                            color = "black")
      }
    }
  }

  plots <- list(
    rank = plot_rank,
    score = plot_score,
    loading = plot_loading
  )
  print(plots$rank)
  print(plots$score)
  print(plots$loading)
  return(plots)
}

