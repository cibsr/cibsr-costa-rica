# knitr::stitch_rmd(script="./___/___.R", output="./___/___/___.md")
#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.
cat("\f") # clear console 

# ---- load-packages -----------------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr) # enables piping : %>% 
library(ggplot2)

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.
source("./scripts/common-functions.R") # used in multiple reports
source("./scripts/graphs/graph-presets.R") # fonts, colors, themes 
source("./scripts/general-graphs.R") 
# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("ggplot2") # graphing
# requireNamespace("readr") # data input
requireNamespace("tidyr") # data manipulation
requireNamespace("dplyr") # Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit")# For asserting conditions meet expected patterns.
# requireNamespace("car") # For it's `recode()` function.

# ---- declare-globals ---------------------------------------------------------

# ---- load-data ---------------------------------------------------------------
# load the product of 0-ellis-island.R,  a list object containing data and metadata
dto <- readRDS("./data-unshared/derived/dto.rds")
# each element this list is another list:
names(dto)
lapply(dto, names)

# ---- utility-functions -------------------------------------------------------
showfreq <- function(d,varname){
  d %>% 
    dplyr::group_by_(varname) %>% 
    dplyr::summarize(n=n())
}
# ---- inspect-data -------------------------------------------------------------


# ---- tweak-data --------------------------------------------------------------
# ds <- dto$dx$gng %>% tibble::as_tibble()
ds <- dto$dx$stern %>% tibble::as_tibble()
ds %>% dplyr::glimpse()
dto %>% showfreq("surveyID")

regex_rule <- "^(\\w+)_(\\w+)_(\\d+)(\\w+)$"
d <- ds %>% 
  dplyr::mutate(
    person_id = gsub(regex_rule,"\\3", person_id),
    correct   = as.logical(correct)
  ) %>% 
  dplyr::rename(
    timepoint = rowname
  )
d

g <- d %>% 
  dplyr::filter(person_id %in% 101:105) %>%
  ggplot(aes(x=timepoint,y=responseTimes,color=correct )) +
  # geom_point(shape=21)+
  geom_text(aes(label = targets), size=2)+
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )+
  facet_wrap("person_id",scales = "free", as.table = T)+
  # theme_minimal()
  theme_void()
g


# ----- graphing-scatters-1  -----------------------------------------------------
ds <- dto$nirs$source
ds
ds <- ds %>% 
    dplyr::mutate(
      # channel = as.integer(channel),
      source  = as.integer(source),
      condition = factor(condition),
      # person_id = as.integer(person_id),
      # person_id = as.integer(person_id),
      age       = as.integer(age),
      male      = as.logical( ifelse(sex=="m",1,0)),
      farm_id   = as.integer(farm_id)
      
    )
ds %>% dplyr::glimpse()
ds %>% showfreq("male")

# ---- basic-table --------------------------------------------------------------

names(ds)
ds %>% showfreq("person_id")
ds %>% showfreq("source")
ds %>% showfreq("condition")
ds %>% showfreq("sex")
ds %>% showfreq("farm_id")

summary(ds$age)


# ---- basic-graph --------------------------------------------------------------

d <- ds
g <- d %>% 
  ggplot(aes(x=person_id, y=value))+
  geom_point()+
  facet_grid(source ~ condition)+
  main_theme+
  theme(
    axis.text.x = element_blank(),
    axis.ticks = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank()
  )
g

####





# ---- publish ---------------------------------------
path_report_1 <- "./reports/*/report_1.Rmd"
path_report_2 <- "./reports/*/report_2.Rmd"
allReports <- c(path_report_1,path_report_2)

pathFilesToBuild <- c(allReports)
testit::assert("The knitr Rmd files should exist.", base::file.exists(pathFilesToBuild))
# Build the reports
for( pathFile in pathFilesToBuild ) {
  
  rmarkdown::render(input = pathFile,
                    output_format=c(
                      # "html_document" # set print_format <- "html" in seed-study.R
                      # "pdf_document"
                      # ,"md_document"
                      "word_document" # set print_format <- "pandoc" in seed-study.R
                    ),
                    clean=TRUE)
}

