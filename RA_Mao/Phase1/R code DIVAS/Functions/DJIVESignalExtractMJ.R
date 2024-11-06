DJIVESignalExtractMJ <- function(datablock, dataname, nsim) {
  # DJIVESignalExtractMJ  Signal matrix extraction
  #      First Step of DJIVE algorithm
  #
  # Inputs:
  #   datablock - list of d_k x n data matrices
  #   dataname - list of strings, each containing a data matrix's name
  #   nsim - number of bootstrap samples
  #
  # Outputs:
  #   VBars - list of adjusted signal row spaces
  #   phiBars - vector of perturbation angles for each data matrix
  #   EHats - list of estimated noise matrices
  #   rBars - vector of adjusted signal ranks for each data matrix
  
  nb <- length(datablock)
  VBars <- vector("list", nb)
  EHats <- vector("list", nb)
  phiBars <- rep(90, nb)
  rBars <- rep(0, nb)
  
  for (ib in seq_len(nb)) {
    cat("Signal estimation for", dataname[[ib]], "\n")
    result <- MatSignalExtractMJ(datablock[[ib]], dataname[[ib]], nsim)
    VBars[[ib]] <- result$VBar
    phiBars[ib] <- result$phiBar
    rBars[ib] <- result$rBar
    EHats[[ib]] <- result$EHat
  }
  
  return(list(VBars = VBars, phiBars = phiBars, EHats = EHats, rBars = rBars))
}
