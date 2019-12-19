# =================================================================== #
# Project: Sources of Misperception
# Author: Patrick
# Date: 12/19/2019
# Summary: check MTurk completion codes etc. before approving HITs
# =================================================================== #


### Packages
library(here)
library(readr)
library(tidyverse)


### Load raw data
mturk <- read_csv(here("data/Batch_3872496_batch_results.csv"))
qualtrics <- read_csv(here("data/Immigration_December 19, 2019_02.00.csv"), skip = 3, 
                      col_names = here("data/Immigration_December 19, 2019_02.00.csv") %>%
                        read_lines(n_max = 1) %>%
                        strsplit(",") %>%
                        unlist)


### Compare survey codes in qualtrics & batch data

## codes submitted to MTurk
table(is.na(mturk$Answer.surveycode))
mturk$surveycode <- as.numeric(mturk$Answer.surveycode)

## check NAs
table(is.na(mturk$surveycode))
mturk$Answer.surveycode[is.na(mturk$surveycode)]

## survey codes generated in qualtrics
qualtrics$surveycode <- qualtrics$`Random ID`
table(is.na(qualtrics$surveycode))

## check for duplicates
length(unique(mturk$Answer.surveycode))
mturk$Answer.surveycode[duplicated(mturk$Answer.surveycode)]
length(unique(qualtrics$surveycode))
qualtrics$surveycode[duplicated(qualtrics$surveycode)]

## check false codes submitted to MTurk
table(mturk$surveycode %in% qualtrics$surveycode)
table(qualtrics$surveycode %in% mturk$surveycode)
qualtrics$surveycode[!qualtrics$surveycode %in% mturk$surveycode]
