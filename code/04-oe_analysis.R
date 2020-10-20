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

# write out
dat %>%
    select(., id, taxes_oe) %>%
    write_csv(., "data/taxes_oe.csv")

dat %>%
    select(., id, jobs_oe) %>%
    write_csv(., "data/jobs_oe.csv")

# read back in processed scores
tmp <- read_csv(here("data/LIWC2015 Results (taxes_oe).csv"))
tmp <- rename(tmp, id = `Source (A)`, tentat_taxes = tentat, certain_taxes = certain)

dat <- tmp %>%
    select(., id, tentat_taxes, certain_taxes) %>%
    left_join(dat, ., by = "id")

tmp <- read_csv(here("data/LIWC2015 Results (jobs_oe).csv"))
tmp <- rename(tmp, id = `Source (A)`, tentat_jobs = tentat, certain_jobs = certain)

dat <- tmp %>%
    select(., id, tentat_jobs, certain_jobs) %>%
    left_join(dat, ., by = "id")

rm(tmp)