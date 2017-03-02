# the purpose of this script is to create a data transfer object (dto)

# run the line below to stitch a basic html output. For elaborated report, run the corresponding .Rmd file
# knitr::stitch_rmd(script="./manipulation/0-ellis-island.R", output="./manipulation/stitched-output/0-ellis-island.md")
#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.
cat("\f") # clear console

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.

# ---- load-packages -----------------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(tidyverse) #Pipes
library(R.matlab)
library()

# ---- declare-globals ---------------------------------------------------------
path_folder_glm  <- "./data-unshared/derived/model/glm"
path_gng         <- paste0(path_folder_glm,"/gng")
path_stern       <- paste0(path_folder_glm,"/stern")
path_wcst        <- paste0(path_folder_glm,"/wcst")

path_files_gng   <- list.files(path_gng, pattern = ".mat",full.names = T)
path_files_stern <- list.files(path_stern, pattern = ".mat",full.names = T)
path_files_wcst  <- list.files(path_wcst, pattern = ".mat",full.names = T)

# ---- load-data ---------------------------------------------------------------
model_file <- R.matlab::readMat(path_files_gng[1])
# input <- R.matlab::readMat(path_files_gng[1])
class(model_file)
# input <- input$gngHome
# input
# str(input)
# class(input)
# dimnames(input)
# attr(input[[1]],"dimnames")
# attr(input,"dim")
# attr(input,"dimnames")
# attr(input,"dimnames")[[1]]

#######################
# element_names <- attr(ls,"dimnames")[[1]]





# ---- define-utility-functions ---------------

# ---- save-to-disk ----------------------------

