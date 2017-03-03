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


# ---- declare-globals ---------------------------------------------------------
path_folder_glm      <- "./data-unshared/derived/model/glm"
path_glm_gng         <- paste0(path_folder_glm,"/gng")
path_glm_stern       <- paste0(path_folder_glm,"/stern")
path_glm_wcst        <- paste0(path_folder_glm,"/wcst")

# path_folder_stern    <- "./data-unshared/raw/stern"
# path_folder_wcst    <- "./data-unshared/raw/wcst"
# 
# path_folder_homer    <- "./data-unshared/derived/homer"

path_files_gng   <- list.files(path_glm_gng, pattern = ".mat",full.names = T)
path_files_stern <- list.files(path_glm_stern, pattern = ".mat",full.names = T)
path_files_wcst  <- list.files(path_glm_wcst, pattern = ".mat",full.names = T)

# ---- load-data ---------------------------------------------------------------
# model_file <- R.matlab::readMat(path_files_gng[1])
model_file <- R.matlab::readMat(path_files_stern[1])
# model_file <- R.matlab::readMat(path_files_wcst[1])
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

get_glm_file <- function(model_file){
  input <- model_file[[1]]
  (element_names <- rownames(input) ) 
  (last <- max(length(input))) # last component, should contain conditions
  
  (condition_names <- rownames(input[[last]]))
  (last_name <- element_names[last])
  (ar_source <- input[[last]] )
  
  # transform the raw .mat into a list object
  ls_input <- list()
  for( i in seq_along(input) ){ 
    ls_input[[ element_names[i] ]] <- input[[i]] 
  } 
  # extract the array with localized sources data
  ls_sources <- list()
  for( i in seq_along(condition_names) ){
    ls_sources[[ condition_names[i] ]] <- ar_source[[i]] %>% t() %>% as.numeric()
  }
  (ds_sources <- dplyr::bind_cols(ls_sources))
  # combine data from channels
  ls_channels <- list()
  for(i in names(ds_sources) ){
    ls_channels[[i]] <- ls_input[[i]] %>% as.numeric()
  }
  (ds_channels <- ls_channels %>% dplyr::bind_cols() )
  # assemble the output objectd
  ls_output <- list()
  ls_output[["channels"]] <- ds_channels
  ls_output[["sources"]]  <- ds_sources
  ls_output[["beta"]]  <- ls_input[["beta"]]
  ls_output[["tval"]]  <- ls_input[["T"]]
  ls_output[["pval"]]  <- ls_input[["P"]]
  return(ls_output)
  
}

ls <- get_glm_file(model_file)



# ---- define-utility-functions ---------------

# ---- save-to-disk ----------------------------

