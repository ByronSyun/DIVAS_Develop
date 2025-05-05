# This file typically contains .onLoad, .onUnload, .onAttach hooks

.onLoad <- function(libname, pkgname) {
  # Check CVXR version upon package load
  if (requireNamespace("CVXR", quietly = TRUE)) {
    required_version <- "0.99-7"
    loaded_version <- as.character(packageVersion("CVXR")) # Ensure string comparison

    if (loaded_version != required_version) {
      packageStartupMessage(paste0(
        "Warning: Package 'DIVAS' requires CVXR version '", required_version, "', ",
        "but version '", loaded_version, "' is loaded. ",
        "Unexpected behavior may occur.\n",
        "Please install the required version using:\n",
        "devtools::install_version('CVXR', version = '", required_version, "', repos = 'http://cran.us.r-project.org')"
      ))
      # Uncomment the following line to stop loading if the version is incorrect
      # stop(paste0("DIVAS requires CVXR version ", required_version, ". Stopping package load."))
    }
  } else {
    # This should ideally not happen if Depends is set correctly and installation worked,
    # but include a message just in case.
    packageStartupMessage("Warning: Required package 'CVXR' is not installed. ",
                          "DIVAS depends on CVXR version 0.99-7.")
    # Uncomment the following line to stop loading if CVXR is missing entirely
    # stop("Required package CVXR is not installed.")
  }

  # Other .onLoad tasks can go here if needed
  invisible() # .onLoad should return invisible() or NULL
}

# can also add .onAttach if you want messages displayed every time the package is attached
# .onAttach <- function(libname, pkgname) {
#   packageStartupMessage("Welcome to DIVAS!")
# }

# .onUnload hook if needed for cleanup
# .onUnload <- function (libpath) {
#   library.dynam.unload("DIVAS", libpath)
# } 