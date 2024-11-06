###########################################################################################
#code to read expert data, implement DIVAS ###################################
### Yinuo Sun, August 2024################################################################
###########################################################################################

library(devtools)
create("DIVAS")

#######################################################################
##specify the directory where R works##################################
#######################################################################
directory_input <- "../R code DIVAS"
setwd(directory_input)

# load other functions
source("Functions/DJIVESignalExtractMJ.R")


#import the data in xxx format
sheet_names <- ("Data/...")


# Develop
devtools::document()
devtools::build()
devtools::install()

# test
devtools::check()