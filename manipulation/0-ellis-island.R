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
library(tibble)


# ---- declare-globals ---------------------------------------------------------
path_folder_glm      <- "./data-unshared/derived/model/glm"
path_glm_gng         <- paste0(path_folder_glm,"/gng")
path_glm_stern       <- paste0(path_folder_glm,"/stern")
path_glm_wcst        <- paste0(path_folder_glm,"/wcst")

path_folder_homer    <- "./data-unshared/derived/homer"
# path_folder_stern    <- "./data-unshared/raw/stern"
# path_folder_wcst    <- "./data-unshared/raw/wcst"
# 
# path_folder_homer    <- "./data-unshared/derived/homer"

path_files_gng   <- list.files(path_glm_gng, pattern = ".mat",full.names = T)
path_files_stern <- list.files(path_glm_stern, pattern = ".mat",full.names = T)
path_files_wcst  <- list.files(path_glm_wcst, pattern = ".mat",full.names = T)

# ---- load-data ---------------------------------------------------------------
# model_file <- R.matlab::readMat(path_files_gng[1])
# model_file <- R.matlab::readMat(path_files_stern[1])
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

# ---- develop-functions ------------------------
# function to extract individual glm file
get_glm_file <- function(file_path){
  model_file <- R.matlab::readMat(file_path)
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
  ls_output[["channel"]] <- ds_channels
  ls_output[["source"]]  <- ds_sources
  ls_output[["beta"]]  <- ls_input[["beta"]]
  ls_output[["tval"]]  <- ls_input[["T"]]
  ls_output[["pval"]]  <- ls_input[["P"]]
  return(ls_output)
  
}
# ls <- get_glm_file("./data-unshared/derived/model/glm/gng/crNirs_glm_gng_062_51_m_f2.mat")
# ls <- get_glm_file("./data-unshared/derived/model/glm/stern/crNirs_glm_stern_062_51_m_f2.mat")
# ls <- get_glm_file("./data-unshared/derived/model/glm/wcst/crNirs_glm_wcst_062_51_m_f2.mat")

# function to assemble ds of a given index from the list of individual glm files
# relies on get_glm_file() to extract individual files
# must provide a list object with files paths to individual glm files
assemble_glm_index <- function(ls_persons, index_name){
  ls_temp <- list()
  for( i in names(ls_persons) ){
    # ls_persons <- ls_index
    # i <- "crNirs_glm_gng_056_63_m_f1"
    # i <- "crNirs_glm_stern_062_51_m_f2"
    # index_name <- "beta"
    # index_name <- "source"
    rows_to_gather <- names(ls_persons[[1]]$source) # source give the authority
    d1 <- ls_persons[[i]][[index_name]]
    if(index_name %in% c("beta","tval","pval")){
      d1 <- d1 %>% as_tibble()
      names(d1) <- rows_to_gather[1:ncol(d1)] # the first columns from source
    }
    rows_to_gather <- names(d1)
    d2 <- d1 %>%  
      tibble::rownames_to_column() %>% 
      tidyr::gather_(key = "condition", value="value",rows_to_gather) %>% 
      dplyr::mutate(index = index_name) 
    # if(index_name=="source"){
    #   d3 <- d2 %>% dplyr::rename(source = rowname)
    # }else{
    #   d3 <- d2 %>% dplyr::rename(channel = rowname)
    # }
    ls_temp[[i]] <- d2
  }
  d <- dplyr::bind_rows(ls_temp,.id="person")
  return(d)
}
# ds_channel <- ls_index %>% assemble_index("channel")
# ds_source <- ls_index %>% assemble_index("source")

# gathers glm data of a given index from all individuals in a folder
# relies on assemble_glm_index() which
# relies on get_glm_file()
assemble_glm <- function(path_folder, index_name){
  # path_folder <- "./data-unshared/derived/model/glm/gng/"
  # path_folder <- "./data-unshared/derived/model/glm/stern/"
  # index_name  <- "channel"
  path_files <- list.files(path_folder, pattern = ".mat",full.names = T)
  
  ls_index <- list()
  for( i in seq_along(path_files) ){
    (path_name <- path_files[i])
    (file_name <- sub(".mat","",basename(path_name)))
    ls_index[[file_name]] <- get_glm_file(path_name)
  }
  d <- ls_index %>% assemble_glm_index(index_name)
}
# ds_channel <-  assemble_glm("./data-unshared/derived/glm/gng","channel")
# ds_source  <-  assemble_glm("./data-unshared/derived/glm/gng","source")
# # TODO. Pre-req : names of the columsn
# ds_beta <-  assemble_glm("./data-unshared/derived/glm/gng","beta")
# ds_tval <-  assemble_glm("./data-unshared/derived/glm/gng","tval")
# ds_pval <-  assemble_glm("./data-unshared/derived/glm/gng","pval")

# function to import a bihavioral data file
get_bx_file <- function(path_file){
  # path_file <-  "./data-unshared/raw/gng/goNoGo_cr_101crNirs.mat"
  # path_file <-  "./data-unshared/raw/stern/sternberg_cr_101crNirs.mat"
  # path_file <-  "./data-unshared/raw/wcst/cardSort_cr_101_crNirs.mat" # differnt structure
  model_file <- R.matlab::readMat(path_file)
  input <- model_file[[1]]
  # input %>% dplyr::glimpse()
  ls_temp <- list()
  (element_names <- rownames(input))
  for(i in seq_along(input) ){
    # input[i] %>% unlist() %>% as.vector()  %>% print()
    ls_temp[[ element_names[i] ]] <- input[i] %>% unlist() %>% as.vector()
  }
  # find what elements contain a single value
  test <- lapply(ls_temp, function(x) ifelse(length(x)==1, 1, 0)) %>%unlist()
  element_single <- names(which(test==1))
  element_multi  <- setdiff(element_names, element_single)
  d <- ls_temp[element_multi] %>% 
    dplyr::bind_cols() %>% as.data.frame()
  for(i in seq_along(element_single)){
    # i <- 1
    d[,element_single[i] ] <- ls_temp[ element_single[i] ]
  }
  d <- d %>% dplyr::select_(.dots = element_names) %>% 
    tibble::rownames_to_column()
  return(d) 
}
# ds <- get_bx_file("./data-unshared/raw/stern/sternberg_cr_95crNirs.mat")
# ds <- get_bx_file("./data-unshared/raw/wcst/cardSort_cr_101_crNirs.mat")
# ds <- get_bx_file("./data-unshared/raw/gng/goNoGo_cr_95crNirs.mat")

# assembles  behavioral data from a given folder
assemble_bx <- function(path_folder){
  # path_folder <- "./data-unshared/raw/gng"
  path_files <- list.files(path_folder, pattern = ".mat",full.names =T )
  ls_temp <- list()
  for( i in seq_along( path_files ) ){
    file_name <- sub(".mat", "", basename(path_files[i]))
    ls_temp[[ file_name ]] <- d <- get_bx_file( path_file = path_files[i] )
  } 
  d <- ls_temp %>% dplyr::bind_rows(.id = "person_id")
  return(d)
}
# ds_bx_gng <- assemble_bx("./data-unshared/raw/gng")
# ds_bx_stern <- assemble_bx("./data-unshared/raw/stern")
# TODO. wcst is of a differnet structure
# ds_bx_wcst <- assemble_bx("./data-unshared/raw/wcst")

# ---- assemble-glm-data -----------------------
# gather the list of person files 
ds_nirs_channel <-  assemble_glm("./data-unshared/derived/model/glm/stern","channel")
ds_nirs_source  <-  assemble_glm("./data-unshared/derived/model/glm/stern","source")
ds_nirs_beta    <-  assemble_glm("./data-unshared/derived/model/glm/stern","beta")
ds_nirs_tval    <-  assemble_glm("./data-unshared/derived/model/glm/stern","tval")
ds_nirs_pval    <-  assemble_glm("./data-unshared/derived/model/glm/stern","pval")

# ---- tweak-glm-data ---------------

regex_pattern <- "(\\w+)_(\\w+)_(\\w+)_(\\d+)_(\\d+)_(\\w{1})_f(\\w+)"
ds_nirs_source <- ds_nirs_source %>% 
  dplyr::mutate(
    model     = gsub(regex_pattern,"\\2", person),
    task      = gsub(regex_pattern,"\\3", person),
    person_id = gsub(regex_pattern,"\\4", person),
    age       = gsub(regex_pattern,"\\5", person),
    sex       = gsub(regex_pattern,"\\6", person),
    farm_id   = gsub(regex_pattern,"\\7", person)
  )
head(ds_nirs_source)
ds_nirs_channel <- ds_nirs_channel %>% 
  dplyr::mutate(
    model     = gsub(regex_pattern,"\\2", person),
    task      = gsub(regex_pattern,"\\3", person),
    person_id = gsub(regex_pattern,"\\4", person),
    age       = gsub(regex_pattern,"\\5", person),
    sex       = gsub(regex_pattern,"\\6", person),
    farm_id   = gsub(regex_pattern,"\\7", person)
  )
head(ds_nirs_channel)
lapply(ds_nirs_channel, table)

# ---- assemble-bx-data -----------------------------

ds_bx_gng <- assemble_bx("./data-unshared/raw/gng")
ds_bx_stern <- assemble_bx("./data-unshared/raw/stern")
# ds_bx_wcst <- assemble_bx("./data-unshared/raw/wcst")

# ---- tweak-bx-data ------------------------------

# ---- assemble-dto --------------------
dto <- list(
  "nirs" = list(),
  "dx"   = list()
)
dto[["nirs"]][["source"]] <- ds_nirs_source
dto[["nirs"]][["channel"]] <- ds_nirs_channel
dto[["dx"]][["gng"]]      <- ds_bx_gng
dto[["dx"]][["stern"]]    <- ds_bx_stern
  
# ---- save-to-disk ------------------
dto %>% saveRDS("./data-unshared/derived/dto.rds")

# ----  -----------------------------
# input a homer file (emerging from homer)
(file_path <- paste0(list.files(path_folder_homer, full.names = T)[1]))
model_file <- R.matlab::readMat(file_path)

# input raw behavioral file
path_folder_raw_stern <- "./data-unshared/raw/stern"
(file_path <- paste0(list.files(path_folder_raw_stern, full.names = T)[1]))
model_file <- R.matlab::readMat(file_path)
input <- model_file[[1]]



names(ds)

target_elements <- c("rest","strings","targets","responses", "responseTimes","correct","compatible")
d <- ls_temp[target_elements] %>% 
  dplyr::bind_cols() %>% 
  dplyr::mutate(
    subject_id = ls_temp[["subjectID"]],
    initRest      = ls_temp[["initRest"]],
    maint      = ls_temp[["encoding"]],
    maint      = ls_temp[["maint"]],
    maint      = ls_temp[["retrieval"]],
    maint      = ls_temp[["finalRest"]]
  )

ls_temp
d <- ls_temp %>% 
d <- dplyr::bind_cols(ls_temp)

str(input)
class(input)
attr(input,"dim")
attr(input,"dimnames")

input[8]
input[8] %>% unlist() %>% as.vector()
input[9] %>% unlist() %>% as.vector()
input[11]

class(model_file)
d <- model_file$dc
class(d)
str(d)

colnames(d)

View(d)
input <- model_file[[1]]
(element_names <- rownames(input) ) 
(last <- max(length(input))) # last component, should contain conditions

(condition_names <- rownames(input[[last]]))
(last_name <- element_names[last])
(ar_source <- input[[last]] )

# ---- save-to-disk ----------------------------





















