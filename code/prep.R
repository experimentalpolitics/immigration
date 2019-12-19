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

num <- read_csv(here("data/Immigration_December 19, 2019_05.20.csv"), skip = 3, 
                col_names = here("data/Immigration_December 19, 2019_05.20.csv") %>%
                  read_lines(n_max = 1) %>%
                  strsplit(",") %>%
                  unlist)

### Check labelled vs. numeric data
table(raw$smedia_1, num$smedia_1, useNA = "always")

### Clean/recode complete set of variables
dat <- num %>% 
  filter(!is.na(`Random ID`)) %>%
  transmute(
    id = row_number(),
    duration = `Duration (in seconds)`,
    smedia_yt = (7 - smedia_1)/6,
    smedia_fb = (7 - smedia_2)/6,
    smedia_ig = (7 - smedia_3)/6,
    smedia_tw = (7 - smedia_4)/6,
    smedia_tb = (7 - smedia_5)/6,
    tv_fox = (7 - tv_1)/6,
    tv_msnbc = (7 - tv_2)/6,
    tv_cnn = (7 - tv_3)/6,
    tv_mbc = (7 - tv_4)/6,
    tv_cbs = (7 - tv_5)/6,
    print_nyt = (7 - print_1)/6,
    print_wapo = (7 - print_2)/6,
    print_wsj = (7 - print_3)/6,
    print_ust = (7 - print_4)/6,
    print_nyp = (7 - print_5)/6,
  )
