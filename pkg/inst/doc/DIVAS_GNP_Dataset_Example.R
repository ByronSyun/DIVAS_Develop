## ----setup-gnp, include = FALSE-----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## ----load-qs-gnp, eval=FALSE--------------------------------------------------
# # install.packages("qs")
# # library(qs)

## ----gnp-example-run, eval=FALSE----------------------------------------------
# # library(qs)
# # gnp_data_path <- system.file("extdata", "gnp_imputed.qs", package = "DIVAS")
# # gnp <- qs::qread(gnp_data_path)
# #
# # datablock_gnp <- gnp$datablock
# # divasRes_gnp <- DIVAS::DIVASmain(datablock_gnp, nsim = 400, colCent = TRUE)
# #
# # # Create names for the data blocks
# # dataname_gnp <- paste0("DataBlock_", names(datablock_gnp))
# # plots_gnp <- DIVAS::DJIVEAngleDiagnosticJP(datablock_gnp, dataname_gnp, divasRes_gnp, 566, "GNP Demo")
# # print(plots_gnp)

