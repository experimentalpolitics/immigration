# =================================================================== #
# Project: Sources of Misperception
# Author: Patrick
# Date: 12/19/2019
# Summary: prepare raw qualtrics dataset for subsequent analyses
# =================================================================== #


### Packages
library(here)
library(readr)
library(tidyverse)


### Load raw data
raw <- read_csv(here("data/Immigration_December 19, 2019_02.00.csv"), skip = 3, 
                col_names = here("data/Immigration_December 19, 2019_02.00.csv") %>%
                  read_lines(n_max = 1) %>%
                  strsplit(",") %>%
                  unlist)


### 