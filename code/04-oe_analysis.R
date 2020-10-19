# =================================================================== #
# Project: Sources of Misperception
# Author: Nick
# Date: 10/19/2020
# Summary: Explore/analyze OE responses using different methods.
# =================================================================== #

# packages
library(here)
library(readr)
library(tidyverse)

# prep the data for LIWC program
dat <- read_csv(here("data/immigration_20191219_clean.csv"))

dat %>%
    select(., id, taxes_oe) %>%
    write_csv(., "data/taxes_oe.csv")

dat %>%
    select(., id, jobs_oe) %>%
    write_csv(., "data/jobs_oe.csv")
