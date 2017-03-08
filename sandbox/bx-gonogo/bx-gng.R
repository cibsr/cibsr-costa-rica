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
# ds <- dto$nirs$channel
# ds <- dto$nirs$source
ds <- dto$dx$gng %>% tibble::as_tibble()
# ds <- dto$dx$stern %>% tibble::as_tibble()
ds %>% dplyr::glimpse()
# dto %>% showfreq("surveyID")

regex_rule <- "^(\\w+)_(\\w+)_(\\d+)(\\w+)$"
ds <- ds %>% 
  dplyr::mutate(
    person_id = gsub(regex_rule,"\\3", person_id) %>% as.integer(),
    rowname   = as.integer(rowname)
  ) %>% 
  dplyr::rename(
    timepoint = rowname,
    response_time = rt,
    seconds  = secs
  ) 
ds %>% dplyr::glimpse()
ds



# ---- basic-table --------------------------------------------------------------

names(ds)
ds %>% showfreq("person_id")
ds %>% showfreq("source")
ds %>% showfreq("condition")
ds %>% showfreq("sex")
ds %>% showfreq("farm_id")

summary(ds$age)


# ---- basic-graph --------------------------------------------------------------

# individual timeserise with X
g <- ds %>% 
  # dplyr::filter(person_id %in% 101:105) %>%
  ggplot(aes(x=timepoint,y=response_time)) +
  geom_line(aes(group=person_id),size=.5, alpha=.5) +
  # geom_point(aes(fill=correct),shape=21, color="black", alpha=1, size=2)+
  # geom_point(aes(shape = target_x_value, fill=correct), size=3)+
  # scale_shape_manual(values = c("X"=21," "=32)) + 
  # geom_text(aes(label = target_x_value ), size=4, nudge_y = +.5)+
  # geom_text(aes(label = target_x_value ,y=Inf), size=4)+
  # scale_fill_manual(values = c("TRUE"="white","FALSE"="salmon"))+
  # scale_color_manual(values = c("TRUE"="white","FALSE"="salmon"))+
  facet_wrap("person_id",scales = "fixed", as.table = T)+
  # theme_tufte()+
  theme_bw() +
  # theme_minimal() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_blank()
  )+
  guides(shape=F)

# theme_void()
g





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

