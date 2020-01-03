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


### Clean/recode complete set of variables
dat <- num %>% 
  filter(!is.na(`Random ID`)) %>%
  transmute(
    id = row_number(),
    duration = `Duration (in seconds)`,
    date = RecordedDate,
    smedia_yt = (7 - smedia_1)/6,  ## 0 = never, 1 = several times a day
    smedia_fb = (7 - smedia_2)/6,
    smedia_ig = (7 - smedia_3)/6,
    smedia_tw = (7 - smedia_4)/6,
    smedia_tb = (7 - smedia_5)/6,
    tv_fox = (7 - tv_1)/6,  ## 0 = never, 1 = several times a day
    tv_msnbc = (7 - tv_2)/6,
    tv_cnn = (7 - tv_3)/6,
    tv_mbc = (7 - tv_4)/6,
    tv_cbs = (7 - tv_5)/6,
    print_nyt = (7 - print_1)/6,  ## 0 = never, 1 = several times a day
    print_wapo = (7 - print_2)/6,
    print_wsj = (7 - print_3)/6,
    print_ust = (7 - print_4)/6,
    print_nyp = (7 - print_5)/6,
    unint_farmers = (st_job_1 - 1)/6,  ## 0 = intelligent, 1 = unintelligent
    unint_teachers = (st_job_2 - 1)/6,
    unint_lawyers = (st_job_3 - 1)/6,
    unint_politicians = (st_job_4 - 1)/6,
    lazy_whites = (st_race_1 - 1)/6,  ## 0 = hard-working, 1 = lazy
    lazy_blacks = (st_race_2 - 1)/6,
    lazy_hispanics = (st_race_3 - 1)/6,
    lazy_asians = (st_race_4 - 1)/6,
    selfish_silent = (st_age_1 - 1)/6,  ## 0 = generous, 1 = selfish
    selfish_boomers = (st_age_2 - 1)/6,
    selfish_genx = (st_age_3 - 1)/6,
    selfish_millenials = (st_age_4 - 1)/6,
    polint = (5 - polint)/4,  ## 0 = never, 1 = always
    problem_economy = (problem_1 - 1)/4,  ## 0 = least important, 1 = most important
    problem_terrorism = (problem_3 - 1)/4,
    problem_immigration = (problem_6 - 1)/4,
    problem_healthcare = (problem_7 - 1)/4,
    problem_environment = (problem_9 - 1)/4,
    conservative = (ideol - 1)/6,  ## 0 = very liberal, 1 = very conservative
    republican = (recode(pid, `1`=6, `2`=2, `3`=4, `4`=4) + 
                    recode(pid_lean, `1`=1, `2`=-1, `3`=0, .missing=0) +
                    recode(pid_rep, `1`=1, `2`=0, .missing=0) +
                    recode(pid_dem, `1`=-1, `2`=0, .missing=0) - 1)/6,
    fox = recode(choice, `1`=1, `2`=0, .missing=0)
  )


### Check labelled vs. numeric data
table(raw$choice, num$choice, useNA = "always")





