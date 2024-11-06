#' Visualize the Optimization Progress of Projected Angles
#'
#' The `ccpOutVisualMJ` function visualizes the projected angles for each data block
#' over optimization iterations. The function allows for saving the plot as a PNG file
#' to the specified directory.
#'
#' @param angleHats A list of numeric vectors representing the projected angles of each data block at different iterations.
#' @param phiBars A numeric vector representing the perturbation angles for each data matrix.
#' @param dataname A character vector containing the names of the data blocks.
#' @param iprint An integer value (0 or 1). If \code{1}, the plot will be saved to the disk. Default is \code{NULL}.
#' @param figdir A character string specifying the directory to save the figure. Default is \code{NULL}, which saves to the current directory if \code{iprint = 1}.
#' @param figname A character string specifying the name of the figure file. Default is \code{"opt_progress"}.
#'
#' @return None. The function generates and optionally saves a plot.
#'
#' @importFrom grDevices png dev.off
#' @importFrom graphics par plot abline legend
#' @export
ccpOutVisualMJ <- function(angleHats, phiBars, dataname, iprint = NULL, figdir = NULL, figname = NULL) {
  # Set default figure name if not provided
  if (is.null(figname) || figname == "") {
    figname <- "opt_progress"
  }

  # Number of data blocks
  nb <- length(phiBars)
  # Number of iterations or time points in angleHats
  T <- length(angleHats[[1]])
  idx <- 1:T

  # Create a plot window with specified layout for the plots
  par(mfrow = c(1, nb), oma = c(0, 0, 2, 0), mar = c(3, 3, 2, 1))

  # Loop through each data block and create a plot for the corresponding angles
  for (ib in 1:nb) {
    plot(idx, angleHats[[ib]], type = "l", lwd = 2,
         xlab = "Iteration Index", ylab = "Projected Angle",
         main = paste0(dataname[[ib]], "\n", figname),
         xlim = c(1, T), ylim = c(0, max(angleHats[[ib]], phiBars[ib], na.rm = TRUE)))

    # Add a horizontal line indicating the perturbation angle
    abline(h = phiBars[ib], col = "green", lty = 2, lwd = 2)

    # Add a legend to indicate the lines plotted
    legend("topright", legend = c("Estimated Angle", "Perturbation Angle"),
           col = c("black", "green"), lty = c(1, 2), lwd = c(2, 2), bty = "n")
  }

  # Save the figure if specified
  if (!is.null(iprint) && iprint == 1) {
    # If figdir is not provided or doesn't exist, set it to the current working directory
    if (is.null(figdir) || !dir.exists(figdir)) {
      message("No valid figure directory found! Saving to the current folder.")
      figdir <- getwd()  # Use the current working directory as a fallback
    }

    # Construct the full path for saving the file
    savestr <- file.path(figdir, paste0(figname, ".png"))

    tryCatch({
      # Activate PNG device to save the plot
      png(savestr, width = 1500, height = 500)
      # Recreate the plot when saving it
      par(mfrow = c(1, nb), oma = c(0, 0, 2, 0), mar = c(3, 3, 2, 1))
      for (ib in 1:nb) {
        plot(idx, angleHats[[ib]], type = "l", lwd = 2,
             xlab = "Iteration Index", ylab = "Projected Angle",
             main = paste0(dataname[[ib]], "\n", figname),
             xlim = c(1, T), ylim = c(0, max(angleHats[[ib]], phiBars[ib], na.rm = TRUE)))
        abline(h = phiBars[ib], col = "green", lty = 2, lwd = 2)
      }
      # Close the PNG device
      dev.off()
      message("Figure saved successfully in: ", savestr)
    }, error = function(e) {
      message("Failed to save figure! Error: ", e)
    })
  }
}
